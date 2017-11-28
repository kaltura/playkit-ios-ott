//
//  OTTUser.swift
//  Pods
//
//  Created by Admin on 17/11/2016.
//
//

import UIKit
import SwiftyJSON

public class OTTLoginResponse: OTTBaseObject {

    public var loginSession: OTTLoginSession?

    private let sessionKey = "loginSession"

    required public init(json:Any) {

        let loginJsonResponse = JSON(json)
        let sessionJson = loginJsonResponse[sessionKey]
        self.loginSession = OTTLoginSession(json: sessionJson.object)

    }
}
