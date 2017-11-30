// ===================================================================================================
// Copyright (C) 2017 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a 
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================

import UIKit
import KalturaNetKit
import PlayKit

@objc public class PhoenixAnalyticsPluginConfig: OTTAnalyticsPluginConfig {
    
    let ks: String
    let partnerId: Int
    
    @objc public init(baseUrl: String, timerInterval: TimeInterval, ks: String, partnerId: Int) {
        self.ks = ks
        self.partnerId = partnerId
        super.init(baseUrl: baseUrl, timerInterval: timerInterval)
    }
}

public class PhoenixAnalyticsPlugin: BaseOTTAnalyticsPlugin {
    
    public override class var pluginName: String { return "PhoenixAnalytics" }
    
    var config: PhoenixAnalyticsPluginConfig! {
        didSet {
            self.interval = config.timerInterval
        }
    }
    
    public required init(player: Player, pluginConfig: Any?, messageBus: MessageBus) throws {
        try super.init(player: player, pluginConfig: pluginConfig, messageBus: messageBus)
        guard let config = pluginConfig as? PhoenixAnalyticsPluginConfig else {
            PKLog.error("missing/wrong plugin config")
            throw PKPluginError.missingPluginConfig(pluginName: PhoenixAnalyticsPlugin.pluginName)
        }
        self.config = config
        self.interval = config.timerInterval
    }
    
    public override func onUpdateConfig(pluginConfig: Any) {
        super.onUpdateConfig(pluginConfig: pluginConfig)
        
        guard let config = pluginConfig as? PhoenixAnalyticsPluginConfig else {
            PKLog.error("plugin config is wrong")
            return
        }
        
        PKLog.debug("new config::\(String(describing: config))")
        self.config = config
    }
    
    /************************************************************/
    // MARK: - KalturaOTTAnalyticsPluginProtocol
    /************************************************************/
    
    override func buildRequest(ofType type: OTTAnalyticsEventType) -> Request? {
       
        guard let player = self.player else {
            PKLog.error("send analytics failed due to nil associated player")
            return nil
        }
        
        guard let mediaEntry = player.mediaEntry else {
            PKLog.error("send analytics failed due to nil mediaEntry")
            return nil
        }
        
        guard let requestBuilder: KalturaRequestBuilder = BookmarkService.actionAdd(baseURL: config.baseUrl,
                                                                                    partnerId: config.partnerId,
                                                                                    ks: config.ks,
                                                                                    eventType: type.rawValue.uppercased(),
                                                                                    currentTime: player.currentTime.toInt32(),
                                                                                    assetId: mediaEntry.id,
                                                                                    fileId: fileId ?? "") else {
                                                                                        return nil
        }
        
        requestBuilder.set { [weak self] (response: Response) in
            PKLog.trace("Response: \(response)")
            
            guard let responseData = response.data else { return }
            let ottResponse = try? OTTResponseParser.parse(data: responseData)
            
            if let error = ottResponse as? OTTError {
                if error.code == "4001" {
                    self?.reportConcurrencyEvent()
                } else if error.code == "500016" {
                    self?.reportKSExpiredEvent()
                } else {
                    
                }
            }
        }
        
        return requestBuilder.build()
    }
}


