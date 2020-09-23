//
//  AIGameState.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/23/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A class representation of a game state.
///
/// This class subclasses `GKState` to maintain integration with GameplayKit and to prevent re-inventing AI
/// assessement mechanics.
class AIGameState: GKState {

    /// The timestamp of the captured state.
    var currentTime: TimeInterval

    /// Whether the exit is open in the captured state.
    var exitOpen: Bool

    /// The list of active input signals in the captured state that link to the exit.
    var activeExitInputs: [GameSignalSender]

    /// The list of inactive input signals in the capture state that link to the exit.
    var inactiveExitInputs: [GameSignalSender]

    /// Initialize a game state object.
    /// - Parameter time: The timestamp of this state.
    /// - Parameter exitStatus: Whether the exit is currently open.
    /// - Parameter inputs: A tuple of inputs that correspond to the active and inactive inputs that link to the exit.
    init(at time: TimeInterval, on exitStatus: Bool, with inputs: ([GameSignalSender], [GameSignalSender])) {
        self.currentTime = time
        self.exitOpen = exitStatus
        (self.activeExitInputs, self.inactiveExitInputs) = inputs
        super.init()
    }

}
