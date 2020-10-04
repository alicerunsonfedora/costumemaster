//
//  AIGameState.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// An abstract class that represents a game state/model.
class AIAbstractGameState: NSObject, GKGameModel {

    /// The list of players in this model.
    var players: [GKGameModelPlayer]? {
        return [player]
    }

    /// The currently active player in this model.
    var activePlayer: GKGameModelPlayer? {
        return player
    }

    /// A string that describes the state to a receiver.
    override var description: String {
        return "AIGameState(at exit: \(self.exit), inputs: \(self.inputs), outputs: \(self.outputs))"
    }

    /// The player in the game state.
    var player: AIAbstractGamePlayer

    /// The position of the exit door.
    var exit: CGPoint = CGPoint.zero

    /// Whether the player can leave the world successfully.
    var escapable: Bool = false

    /// The list of all available inputs in the world.
    var inputs: [AIAbstractGameSignalSender] = []

    /// The list of all available outputs in the world.
    var outputs: [AIAbstractGameSignalReceivable] = []

    /// A list of objects that the player can pick up.
    var interactableObjects: [CGPoint] = []

    /// Instantiate a game state.
    /// - Parameter player: The player that is in the world.
    init(with player: AIAbstractGamePlayer) {
        self.player = player
    }

    /// Sets the game model’s internal state to that of the specified game model.
    /// - Parameter gameModel: The game model to set the internal model to.
    func setGameModel(_ gameModel: GKGameModel) {
        guard let model = gameModel as? AIAbstractGameState else { return }
        self.exit = model.exit
        self.inputs = model.inputs
        self.outputs = model.outputs
        self.interactableObjects = model.interactableObjects
        self.player = model.player

        self.escapable = !model.inputs.filter { (input: AIAbstractGameSignalSender) in
            input.outputs.contains(self.exit)
        }.isEmpty

    }

    /// Returns the set of moves available to the specified player.
    /// - Parameter player: An instance of your game’s player class representing the player
    /// whose moves are to be evaluated.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves = [AIGameDecision]()
        for move in AIGamePlayerAction.allCases {
            moves.append(AIGameDecision(by: move, with: self.score(for: player)))
        }
        return moves
    }

    /// Updates the internal state of the game model to reflect the specified changes.
    /// - Parameter gameModelUpdate: An instance of your custom class that implements the
    /// GKGameModelUpdate protocol, describing a move to be made in your game.
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let update = gameModelUpdate as? AIGameDecision else { return }
        switch update.action {
        case .moveUp, .moveDown:
            self.player.position.y += 64 * (update.action == .moveUp ? 1 : -1)
        case .moveLeft, .moveRight:
            self.player.position.x += 64 * (update.action == .moveRight ? 1 : -1)
        case .deployClone, .retractClone:
            self.player.deployedClone.toggle()
        case .switchToNextCostume:
            self.player.nextCostume()
        case .switchToPreviousCostume:
            self.player.prevCostume()
        case .pickup, .drop:
            for object in self.interactableObjects where object.distance(between: self.player.position) < 64 {
                if self.player.inventory.contains(object) {
                    self.player.inventory.removeAll { obj in obj == object }
                } else {
                    self.player.inventory.append(object)
                }
            }
        default:
            break
        }
    }

    /// Create a copy of this object.
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIAbstractGameState(with: self.player)
        copy.exit = self.exit
        copy.inputs = self.inputs
        copy.outputs = self.outputs
        copy.escapable = self.escapable
        copy.player = self.player
        copy.interactableObjects = self.interactableObjects
        copy.setGameModel(self)
        return copy
    }

    /// Returns whether the current state is a winning state.
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let agent = player as? AIAbstractGamePlayer else { return false }
        return agent.position.distance(between: self.exit) < 64 && self.escapable
    }

    /// Returns an integer that scores the current state.
    func score(for player: GKGameModelPlayer) -> Int {
        guard let agent = player as? AIAbstractGamePlayer else { return -999 }
        return Int.random(in: 1...10)
    }

}
