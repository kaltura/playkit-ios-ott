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


extension KalturaRequestBuilder {
    
    @discardableResult
    internal func setOTTBasicParams() -> Self {
        self.setClientTag(clientTag: "java:16-09-10")
        self.setApiVersion(apiVersion: "3.6.1078.11798")
        return self
    }
    
}
