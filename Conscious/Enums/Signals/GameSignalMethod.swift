//
//  GameSignalMethod.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration that represents the different requirements for an output to activate.
public enum GameSignalMethod {
    /// Any input is accepted.
    case anyInput

    /// All inputs must be accepted.
    case allInputs

    /// No input is required.
    case noInput

    /// The inverse of any input is accepted.
    case inverseAnyInput

    /// The inverse of all inputs is accepted.
    case inverseAllInputs
}
