//
//  String.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension String {

    /// Returns a copy of itself that conforms to NSObjectProtocol.
    func toProtocol() -> NSObjectProtocol { self as NSObjectProtocol }
}
