//
//  OTTSession.swift
//  Pods
//
//  Created by Rivka Peleg on 24/11/2016.
//
//

import UIKit
import SwiftyJSON

public class OTTSession: OTTBaseObject {

    public var tokenExpiration: Date?
    public var udid: String?

    let tokenExpirationKey = "expiry"
    let udidKey = "udid"

    required public init?(json: Any) {
        let jsonObject = JSON(json)
        if let time = jsonObject[tokenExpirationKey].number?.doubleValue {
          self.tokenExpiration =  Date.init(timeIntervalSince1970:time)
        }

        self.udid = jsonObject[udidKey].string

    }
}
