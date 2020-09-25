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
/// This class subclasses `GKGameModel` to maintain integration with GameplayKit and to prevent re-inventing AI
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

    /// Describes the contents of this class to its receiver.
    override var description: String {
        return "AIGameState(Timestamp: \(currentTime), "
            + "Current Player: \(String(describing: self.activePlayer)), Exit Open: \(self.exitOpen), "
            + "Exit Position: \(self.exitPosition), Active Inputs: \(self.activeExitInputs))"
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

    /// The position at which the exit lies on. Defaults to an empty position (0, 0).
    var exitPosition: CGPoint = CGPoint.zero

    // MARK: METHODS

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
            self.currentTime = state.currentTime
            self.exitOpen = state.exitOpen
            self.activeExitInputs = state.activeExitInputs
            self.inactiveExitInputs = state.inactiveExitInputs
            self.currentPlayer = state.currentPlayer
            self.exitPosition = state.exitPosition
        }
    }

    /// Returns the set of moves available to the specified player.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves = [AIBaseAgentMove]()
        for move in AIBaseAgentMoveAction.allCases {
            moves.append(AIBaseAgentMove(with: move))
        }
        return moves
    }

    /// Updates the internal state of the game model to reflect the specified changes.
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let update = gameModelUpdate as? AIBaseAgentMove {
            switch update.action {
            case .moveUp, .moveDown, .moveLeft, .moveRight:
                self.currentPlayer.run {
                    self.currentPlayer.move(
                        PlayerMoveDirection.mappedFromAction(update.action),
                        withRespectTo: CGSize(width: 128, height: 128)
                    )
                }
            case .switchToPreviousCostume, .switchToNextCostume:
                self.currentPlayer.run {
                    self.currentPlayer.switchCostume(direction: update.action)
                }
            case .deployClone, .retractClone:
                self.currentPlayer.run {
                    self.currentPlayer.toggleDeployedClones()
                }
            default:
                self.currentPlayer.run {
                    self.currentPlayer.player.halt()
                }
            }
        }
    }

    /// Make a copy of this object.
    func copy(with zone: NSZone? = nil) -> Any {
        let newState = AIGameState(
            at: self.currentTime,
            on: self.exitOpen,
            with: ([], []),
            for: self.currentPlayer
        )
        newState.exitPosition = self.exitPosition
        for input in self.activeExitInputs {
            newState.activeExitInputs.append(input)
        }

        for input in self.inactiveExitInputs {
            newState.inactiveExitInputs.append(input)
        }
        newState.setGameModel(self)
        return newState
    }

    /// Determine whether the state is a winning state for the player.
    ///
    /// A winning state for the base AI game state is determined by whether the player is close to the exit (node
    /// distance of 5.0 or less) and the exit is activated.
    func isWin(for player: GKGameModelPlayer) -> Bool {
        if let realPlayer = player as? AIBaseAgent {
            return self.exitOpen && realPlayer.player.position.distance(between: exitPosition) < 5
        }
        return self.exitOpen
    }

    /// Determine whether the state is a losing state for the player.
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        return false
    }

    /// Determine the score of the state for the player.
    /// - Important: Depending on the game model in question, this should be modified to specify the scoring system.
    /// By default, this will return the default scoring system.
    /// - Parameter player: The current player in this state.
    func score(for player: GKGameModelPlayer) -> Int {
        return defaultScoringSystem(for: player)
    }

    /// Use the default scoring system for the state.
    /// - Parameter player: The current player in this state.
    /// - Returns: A random value between 1 and 10.
    func defaultScoringSystem(for player: GKGameModelPlayer) -> Int {
        return Int.random(in: 1...10)
    }
}
