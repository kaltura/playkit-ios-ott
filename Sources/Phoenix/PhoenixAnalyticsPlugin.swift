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
import SwiftyJSON

@objc public class PhoenixAnalyticsPluginConfig: OTTAnalyticsPluginConfig {
    
    let ks: String
    let partnerId: Int
    
    @objc public init(baseUrl: String, timerInterval: TimeInterval, ks: String, partnerId: Int) {
        self.ks = ks
        self.partnerId = partnerId
        super.init(baseUrl: baseUrl, timerInterval: timerInterval)
    }
    
    public static func parse(json: JSON) -> PhoenixAnalyticsPluginConfig? {
        guard let jsonDictionary = json.dictionary else { return nil }
        guard let baseUrl = jsonDictionary["baseUrl"]?.string,
            let timerInterval = jsonDictionary["timerInterval"]?.double,
            let ks = jsonDictionary["ks"]?.string,
            let partnerId = jsonDictionary["partnerId"]?.int else { return nil }
        
        return PhoenixAnalyticsPluginConfig(baseUrl: baseUrl, timerInterval: timerInterval, ks: ks, partnerId: partnerId)
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
        
        var _config: PhoenixAnalyticsPluginConfig?
        if let json = pluginConfig as? JSON {
            _config = PhoenixAnalyticsPluginConfig.parse(json: json)
        } else {
            _config = pluginConfig as? PhoenixAnalyticsPluginConfig
        }
        
        guard let config = _config else {
            PKLog.error("missing/wrong plugin config")
            throw PKPluginError.missingPluginConfig(pluginName: PhoenixAnalyticsPlugin.pluginName).asNSError
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
        
        requestBuilder.set { (response: Response) in
            PKLog.trace("Response: \(response)")
            
            guard let responseData = response.data else { return }
            let ottResponse = try? OTTResponseParser.parse(data: responseData)
            
            if let error = ottResponse as? OTTError {
                if error.code == "4001" {
                    self.reportConcurrencyEvent()
                } else if error.code == "500016" {
                    self.reportKSExpiredEvent()
                } else {
                    
                }
            }
        }
        
        return requestBuilder.build()
    }
}


