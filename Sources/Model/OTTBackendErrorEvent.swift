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
import PlayKit

/// OTT Event
public class OTTBackendErrorEvent : PKEvent {
    
    class KSExpired : OTTBackendErrorEvent {}
    
    public static let ksExpired: OTTBackendErrorEvent.Type = KSExpired.self
}

