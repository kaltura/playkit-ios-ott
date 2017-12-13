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

public class OTTError: OTTBaseObject {

    public var message: String?
    public var code: String?

    let errorKey = "error"
    let messageKey = "message"
    let codeKey = "code"

    required public init?(json: Any) {

        let jsonObj: JSON = JSON(json)
        let errorDict = jsonObj[errorKey]
        self.message = errorDict[messageKey].string
        self.code = errorDict[codeKey].string
    }

}

public enum OTTErrorCode: Int {
    
    case UserNotActivated = 2016
    
}
