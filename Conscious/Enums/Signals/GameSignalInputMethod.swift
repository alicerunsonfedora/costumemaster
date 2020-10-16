//
//  GameSignalInputMethod.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration that defines the different types of inputs that are used in the game.
/// - Important: This has been moved to `GameSignalSender.InputMethod`.
@available(*, deprecated, renamed: "GameSignalSender.InputMethod")
public enum GameSignalInputMethod {

    /// The input is active once and remains active permanently.
    case activeOncePermanently

    /// The input is active when a player interacts with it, either by distance or collision.
    case activeByPlayerIntervention

    /// The input is active on a timer and then deactivates.
    case activeOnTimer
}
