//
//  Preferences_Win.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import Foundation
import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let sound = Self("sound")
    static let controls = Self("controls")
    static let advanced = Self("advanced")
}
