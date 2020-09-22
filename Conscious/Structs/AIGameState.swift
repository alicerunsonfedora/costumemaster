//
//  AIGameState.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/21/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A data structure that represents a game state.
struct AIGameState {

    /// Whether the exit door is open.
    public let exitOpen: Bool

    /// The list of all active inputs that link up to the exit.
    public let activeExitInputs: [GameSignalSender]

    /// The list of all inactive inputs that link up to the exit.
    public let inactiveExitInputs: [GameSignalSender]

    /// The timestamp of the state when it was captured.
    public let timestamp: TimeInterval

    /// Create a game state.
    /// - Parameter time: The time the state was captured.
    /// - Parameter exit: Whether the exit door is open.
    /// - Parameter inputs: A tuple of the active and inactive inputs.
    init(at time: TimeInterval, on exit: Bool, with inputs: ([GameSignalSender], [GameSignalSender])) {
        self.exitOpen = exit
        self.timestamp = time
        (self.activeExitInputs, self.inactiveExitInputs) = inputs
    }

}
