//
//  OTTLoginSession.swift
//  Pods
//
//  Created by Rivka Peleg on 04/12/2016.
//
//

import UIKit
import SwiftyJSON

public class OTTLoginSession: OTTBaseObject {

    public var ks: String?
    public var refreshToken: String?

    private let ksKey = "ks"
    private let refreshTokenKey = "refreshToken"

    required public init(json:Any) {

        let jsonObject = JSON(json)
        self.ks = jsonObject[ksKey].string
        self.refreshToken = jsonObject[refreshTokenKey].string

    }
}
