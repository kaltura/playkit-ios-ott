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
import SwiftyJSON
import KalturaNetKit
import PlayKit

@objc public enum AssetType: Int {
    case media
    case epg
    case unknown
    
    var asString: String {
        switch self {
        case .media: return "media"
        case .epg: return "epg"
        case .unknown: return ""
        }
    }
}


@objc public enum PlaybackContextType: Int {
    
    case trailer
    case catchup
    case startOver
    case playback
    case unknown
    
    var asString: String {
        switch self {
        case .trailer: return "TRAILER"
        case .catchup: return "CATCHUP"
        case .startOver: return "START_OVER"
        case .playback: return "PLAYBACK"
        case .unknown: return ""
        }
    }
}


/************************************************************/
// MARK: - PhoenixMediaProviderError
/************************************************************/

public enum PhoenixMediaProviderError: PKError {

    case invalidInputParam(param: String)
    case unableToParseData(data: Any)
    case noSourcesFound
    case serverError(code:String, message:String)
    /// in case the response data is empty
    case emptyResponse

    public static let domain = "com.kaltura.playkit.ott.error.PhoenixMediaProvider"
    
    public var code: Int {
        switch self {
        case .invalidInputParam: return 0
        case .unableToParseData: return 1
        case .noSourcesFound: return 2
        case .serverError: return 3
        case .emptyResponse: return 4
        }
    }

    public var errorDescription: String {

        switch self {
        case .invalidInputParam(let param): return "Invalid input param: \(param)"
        case .unableToParseData(let data): return "Unable to parse object (data: \(String(describing: data)))"
        case .noSourcesFound: return "No source found to play content"
        case .serverError(let code, let message): return "Server Error code: \(code), \n message: \(message)"
        case .emptyResponse: return "Response data is empty"
        }
    }

    public var userInfo: [String: Any] {
        switch self {
        case .serverError(let code, let message): return [PKErrorKeys.MediaEntryProviderServerErrorCodeKey: code,
                                                          PKErrorKeys.MediaEntryProviderServerErrorMessageKey: message]
        default:
            return [String: Any]()
        }
    }
}

/************************************************************/
// MARK: - PhoenixMediaProvider
/************************************************************/

@objc public class PhoenixMediaProvider: NSObject, MediaEntryProvider {
    
    @objc public var ks: String?
    @objc public var baseUrl: String?
    @objc public var assetId: String?
    @objc public var type: AssetType = .unknown
    @objc public var formats: [String]?
    @objc public var fileIds: [String]?
    @objc public var playbackContextType: PlaybackContextType = .unknown
    @objc public var networkProtocol: String?
    @objc public var referrer: String?
    
    let defaultProtocol = "https"

    public var executor: RequestExecutor?

    public override init() { }

    /// Required parameter
    ///
    /// - Parameter ks: ks obtained from the application
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(ks: String?) -> Self {
        self.ks = ks
        return self
    }

    /// Required parameter
    ///
    /// - Parameter baseUrl: server url
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(baseUrl: String?) -> Self {
        self.baseUrl = baseUrl
        return self
    }
    
    /// Required parameter
    ///
    /// - Parameter assetId: asset identifier
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(assetId: String?) -> Self {
        self.assetId = assetId
        return self
    }

    /// - Parameter type: Asset Object type if it is Media Or EPG
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(type: AssetType) -> Self {
        self.type = type
        return self
    }

    /// - Parameter playbackContextType: Trailer/Playback/StartOver/Catchup
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(playbackContextType: PlaybackContextType) -> Self {
        self.playbackContextType = playbackContextType
        return self
    }

    /// - Parameter formats: Asset's requested file formats,
    /// According to this formats array order the sources will be ordered in the mediaEntry
    /// According to this formats sources will be filtered when creating the mediaEntry
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(formats: [String]?) -> Self {
        self.formats = formats
        return self
    }

    /// - Parameter formats: Asset's requested file ids,
    /// According to this files array order the sources will be ordered in the mediaEntry
    /// According to this ids sources will be filtered when creating the mediaEntry
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(fileIds: [String]?) -> Self {
        self.fileIds = fileIds
        return self
    }

    /// - Parameter networkProtocol: http/https
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(networkProtocol: String?) -> Self {
        self.networkProtocol = networkProtocol
        return self
    }

    /// - Parameter referrer: the referrer
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(referrer: String?) -> Self {
        self.referrer = referrer
        return self
    }
    
    /// - Parameter executor: executor which will be used to send request.
    ///    default is USRExecutor
    /// - Returns: Self
    @discardableResult
    @nonobjc public func set(executor: RequestExecutor?) -> Self {
        self.executor = executor
        return self
    }
    
    public func cancel() {
        
    }
    
    @objc public func loadMedia(callback: @escaping (PKMediaEntry?, Error?) -> Void) {
        guard let ks = self.ks else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "ks" ).asNSError )
            return
        }
        guard let baseUrl = self.baseUrl else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "baseUrl" ).asNSError )
            return
        }
        guard let assetId = self.assetId else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "assetId" ).asNSError)
            return
        }
        guard self.type != .unknown else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "type" ).asNSError)
            return
        }
        guard self.playbackContextType != .unknown  else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param: "contextType" ).asNSError)
            return
        }

        let playbackContextOptions = PlaybackContextOptions(playbackContextType: playbackContextType, protocls: [networkProtocol ?? defaultProtocol], assetFileIds: fileIds, referrer: referrer)
        
        guard let requestBuilder: KalturaRequestBuilder = OTTAssetService.getPlaybackContext(baseURL: baseUrl, ks: ks, assetId: assetId, type: type, playbackContextOptions: playbackContextOptions) else {
            callback(nil, PhoenixMediaProviderError.invalidInputParam(param:"requests params").asNSError)
            return
        }
        
        let request = requestBuilder.set(completion: { [weak self] (response: Response) in
            if let error = response.error {
                // if error is of type `PKError` pass it as `NSError` else pass the `Error` object.
                callback(nil, (error as? PKError)?.asNSError ?? error)
            }
            
            guard let responseData = response.data else {
                callback(nil, PhoenixMediaProviderError.emptyResponse.asNSError)
                return
            }
            
            var playbackContext: OTTBaseObject? = nil
            do {
                playbackContext = try OTTResponseParser.parse(data: responseData)
            } catch {
                callback(nil, PhoenixMediaProviderError.unableToParseData(data: responseData).asNSError)
            }
            
            if let context = playbackContext as? OTTPlaybackContext {
                if let tuple = self?.createMediaEntry(context: context) {
                    if let error = tuple.1 {
                        callback(nil, error)
                    } else if let media = tuple.0 {
                        if let sources = media.sources, sources.count > 0 {
                            callback(media, nil)
                        } else {
                            callback(nil, PhoenixMediaProviderError.noSourcesFound.asNSError)
                        }
                    }
                }
            } else if let error = playbackContext as? OTTError {
                callback(nil, PhoenixMediaProviderError.serverError(code: error.code ?? "", message: error.message ?? "").asNSError)
            } else {
                callback(nil, PhoenixMediaProviderError.unableToParseData(data: responseData).asNSError)
            }
        }).build()
        
        let executor = self.executor ?? USRExecutor.shared
        executor.send(request: request)
    }

    public func createMediaEntry(context: OTTPlaybackContext) -> (PKMediaEntry?, NSError?) {

        if context.hasBlockAction() != nil {
            if let error = context.hasErrorMessage() {
                return (nil, PhoenixMediaProviderError.serverError(code: error.code ?? "", message: error.message ?? "").asNSError)
            }
            return (nil, PhoenixMediaProviderError.serverError(code: "Blocked", message: "Blocked").asNSError)
        }
        
        guard let assetId = assetId else {
            return (nil, PhoenixMediaProviderError.invalidInputParam(param: "assetId" ).asNSError)
        }
        
        let mediaEntry = PKMediaEntry(id: assetId)
        let sortedSources = sortedAndFilterSources(context.sources)

        var maxDuration: Float = 0.0
        let mediaSources = sortedSources.flatMap { (source: OTTPlaybackSource) -> PKMediaSource? in

            let format = FormatsHelper.getMediaFormat(format: source.format, hasDrm: source.drm != nil)
            guard  FormatsHelper.supportedFormats.contains(format) else {
                return nil
            }

            var drm: [DRMParams]? = nil
            if let drmData = source.drm, drmData.count > 0 {
                drm = drmData.flatMap({ (drmData: OTTDrmData) -> DRMParams? in

                    let scheme = convertScheme(scheme: drmData.scheme)
                    guard FormatsHelper.supportedSchemes.contains(scheme) else {
                        return nil
                    }

                    switch scheme {
                    case .fairplay:
                        // if the scheme is type fair play and there is no certificate or license URL
                        guard let certifictae = drmData.certificate
                            else { return nil }
                        return FairPlayDRMParams(licenseUri: drmData.licenseURL, scheme: scheme, base64EncodedCertificate: certifictae)
                    default:
                        return DRMParams(licenseUri: drmData.licenseURL, scheme: scheme)
                    }
               })

                // checking if the source is supported with his drm data, cause if the source has drm data but from some reason the mapped drm data is empty the source is not playable
                guard let mappedDrmData = drm, mappedDrmData.count > 0  else {
                    return nil
                }
            }

            let mediaSource = PKMediaSource(id: "\(source.id)")
            mediaSource.contentUrl = source.url
            mediaSource.mediaFormat = format
            mediaSource.drmData = drm

            maxDuration = max(maxDuration, source.duration)
            return mediaSource

        }

        mediaEntry.sources = mediaSources
        mediaEntry.duration = TimeInterval(maxDuration)

        return (mediaEntry, nil)
    }

    /// Sorting and filtering source accrding to file formats or file ids
    func sortedAndFilterSources(_ sources: [OTTPlaybackSource]) -> [OTTPlaybackSource] {
        
        let orderedSources = sources.filter({ (source: OTTPlaybackSource) -> Bool in
            if let formats = formats {
                return formats.contains(source.type)
            } else if let  fileIds = fileIds {
                return fileIds.contains("\(source.id)")
            } else {
                return true
            }
        })
            .sorted { (source1: OTTPlaybackSource, source2: OTTPlaybackSource) -> Bool in
                
                if let formats = formats {
                    let index1 = formats.index(of: source1.type) ?? 0
                    let index2 = formats.index(of: source2.type) ?? 0
                    return index1 < index2
                } else if let  fileIds = fileIds {
                    let index1 = fileIds.index(of: "\(source1.id)") ?? 0
                    let index2 = fileIds.index(of: "\(source2.id)") ?? 0
                    return index1 < index2
                } else {
                    return false
                }
        }
        
        return orderedSources
    }

    // Mapping between server scheme and local definision of scheme
    func convertScheme(scheme: String) -> DRMParams.Scheme {
            switch (scheme) {
            case "WIDEVINE_CENC":
                return .widevineCenc
            case "PLAYREADY_CENC":
                return .playreadyCenc
            case "WIDEVINE":
                return .widevineClassic
            case "FAIRPLAY":
                return .fairplay
            default:
                return .unknown
            }
    }

}
