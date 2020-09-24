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
class AIGameState: NSObject, GKGameModel {

    // MARK: COMPUTED PROPERTIES

    /// The list of players in the game.
    var players: [GKGameModelPlayer]? {
        return [self.currentPlayer]
    }

    /// The currently active player.
    var activePlayer: GKGameModelPlayer? {
        return self.currentPlayer
    }

    // MARK: STORED PROPERTIES

    /// The currently active player.
    var currentPlayer: AIBaseAgent

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
    init(
        at time: TimeInterval,
        on exitStatus: Bool,
        with inputs: ([GameSignalSender], [GameSignalSender]),
        for player: AIBaseAgent
    ) {
        self.currentTime = time
        self.exitOpen = exitStatus
        (self.activeExitInputs, self.inactiveExitInputs) = inputs
        self.currentPlayer = player
    }

    /// Sets the game model’s internal state to that of the specified game model.
    /// - Parameter gameModel: The game model to reference from the internal state.
    func setGameModel(_ gameModel: GKGameModel) {
        if let state = gameModel as? AIGameState {
            currentTime = state.currentTime
            exitOpen = state.exitOpen
            activeExitInputs = state.activeExitInputs
            inactiveExitInputs = state.inactiveExitInputs
            self.currentPlayer = state.currentPlayer
        }
    }

    /// Returns the set of moves available to the specified player.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // TODO: Implement this method.
        return nil
    }

    /// Updates the internal state of the game model to reflect the specified changes.
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        // TODO: Implement this method.
    }

    /// Make a copy of this object.
    func copy(with zone: NSZone? = nil) -> Any {
        let newState = AIGameState(
            at: self.currentTime,
            on: self.exitOpen,
            with: ([], []),
            for: self.currentPlayer
        )
        for input in self.activeExitInputs {
            newState.activeExitInputs.append(input)
        }

        for input in self.inactiveExitInputs {
            newState.inactiveExitInputs.append(input)
        }
        newState.setGameModel(self)
        return newState
    }

}
