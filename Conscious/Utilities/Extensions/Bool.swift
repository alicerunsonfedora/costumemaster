//
//  Bool.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/10/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Bool {

    /// Returns a Python string representation of itself.
    func toPythonString() -> String { self ? "True" : "False" }
}
