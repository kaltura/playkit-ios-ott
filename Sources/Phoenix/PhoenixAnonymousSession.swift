//
//  PhoenixAnonymousSession.swift
//  KalturaPlayer
//
//  Created by Vadik on 29/11/2017.
//

import Foundation
import KalturaNetKit
import PlayKit

public enum PhoenixAnonymousSessionError: PKError {
    case unableToParseData(data: Any)

    public static let domain = "com.kaltura.playkit.ott.error.PhoenixAnonymousSession"
    
    public var userInfo: [String : Any] {
        return [:]
    }
    
    public var code: Int {
        return 0
    }
    
    public var errorDescription: String {
        switch self {
        case .unableToParseData(let data):
            return "Unable to parse object (data: \(String(describing: data)))"
        }
    }
}

public class PhoenixAnonymousSession {
    public class func get(baseUrl: String, partnerId: Int64, completion: @escaping (String?, Error?) -> Void) {
        if let b = OttUserService.anonymousLogin(baseURL: baseUrl, partnerId: partnerId) {
            b.set(completion: { (response) in
                if let error = response.error {
                   completion(nil, error)
                } else {
                    guard let responseData = response.data else { return }
                    do {
                        let loginSession = try OTTResponseParser.parse(data: responseData) as? OTTLoginSession
                        completion(loginSession?.ks, nil)
                    } catch {
                        completion(nil, PhoenixAnonymousSessionError.unableToParseData(data: responseData).asNSError)
                    }
                }
            })
            USRExecutor.shared.send(request: b.build())
        }
    }
}
