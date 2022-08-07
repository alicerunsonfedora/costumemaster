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
    /// A structure that defines a state assessement.
    public struct Assessement {
        /// Can the agent escape?
        let canEscape: Bool

        /// Is the agent near the exit?
        let nearExit: Bool

        /// Is the agent near an input device?
        let nearInput: Bool

        /// Is the closest input nearby active?
        let inputActive: Bool

        /// Is the closest input device relevant to opening the exit?
        let inputRelevant: Bool

        /// Does the closest input require a heavy object?
        let requiresObject: Bool

        /// Does the closest input require a specific costume?
        let requiresCostume: Bool

        /// Is the agent wearing the right costume?
        let wearingCostume: Bool

        /// Does the agent have an object in its inventory?
        let hasObject: Bool

        /// Is the agent near an object?
        let nearObject: Bool

        /// Are all of the inputs that send signals to the exit door active?
        let allInputsActive: Bool

        /// Returns a copy of the assessement as an example for decision trees.
        func toList() -> [AnyHashable] {
            [
                canEscape,
                nearExit,
                nearInput,
                inputActive,
                inputRelevant,
                requiresObject,
                requiresCostume,
                wearingCostume,
                hasObject,
                nearObject,
                allInputsActive,
            ]
        }

        /// Returns a copy of the assessement as a dictionary suitable for decision trees.
        func toDict() -> [AnyHashable: NSObjectProtocol] {
            [
                "canEscape?": canEscape as NSObjectProtocol,
                "nearExit?": nearExit as NSObjectProtocol,
                "nearInput?": nearInput as NSObjectProtocol,
                "inputActive?": inputActive as NSObjectProtocol,
                "inputRelevant?": inputRelevant as NSObjectProtocol,
                "requiresObject?": requiresObject as NSObjectProtocol,
                "wearingCostume?": wearingCostume as NSObjectProtocol,
                "requiresCostume?": requiresCostume as NSObjectProtocol,
                "hasObject?": hasObject as NSObjectProtocol,
                "nearObj?": nearObject as NSObjectProtocol,
                "allInputsActive?": allInputsActive as NSObjectProtocol,
            ]
        }
    }

    /// The list of players in this model.
    var players: [GKGameModelPlayer]? {
        [player]
    }

    /// The currently active player in this model.
    var activePlayer: GKGameModelPlayer? {
        player
    }

    /// A string that describes the state to a receiver.
    override var description: String {
        "AIGameState(at exit: \(exit), inputs: \(inputs), outputs: \(outputs))"
    }

    /// The player in the game state.
    var player: AIAbstractGamePlayer

    /// The position of the exit door.
    public var exit: CGPoint = .zero

    /// Whether the player can leave the world successfully.
    public var escapable: Bool = false

    /// The list of all available inputs in the world.
    public var inputs: [AIAbstractGameSignalSender] = []

    /// The list of all available outputs in the world.
    public var outputs: [AIAbstractGameSignalReceivable] = []

    /// A list of objects that the player can pick up.
    public var interactableObjects: [CGPoint] = []

    /// Instantiate a game state.
    /// - Parameter player: The player that is in the world.
    init(with player: AIAbstractGamePlayer) {
        self.player = player
    }

    /// Sets the game model’s internal state to that of the specified game model.
    /// - Parameter gameModel: The game model to set the internal model to.
    func setGameModel(_ gameModel: GKGameModel) {
        guard let model = gameModel as? AIAbstractGameState else { return }
        exit = model.exit
        inputs = model.inputs
        outputs = model.outputs
        interactableObjects = model.interactableObjects
        player = model.player

        escapable = !model.inputs.filter { (input: AIAbstractGameSignalSender) in
            input.outputs.contains(self.exit)
        }.isEmpty
    }

    /// Returns the set of moves available to the specified player.
    /// - Parameter player: An instance of your game’s player class representing the player
    /// whose moves are to be evaluated.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves = [AIGameDecision]()
        for move in AIGamePlayerAction.allCases {
            moves.append(AIGameDecision(by: move, with: score(for: player)))
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
            player.position.y += 64 * (update.action == .moveUp ? 1 : -1)
        case .moveLeft, .moveRight:
            player.position.x += 64 * (update.action == .moveRight ? 1 : -1)
        case .deployClone, .retractClone:
            player.deployedClone.toggle()
        case .switchToNextCostume:
            player.nextCostume()
        case .switchToPreviousCostume:
            player.prevCostume()
        case .pickup, .drop:
            for object in interactableObjects where object.distance(between: player.position) < 64 {
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
    func copy(with _: NSZone? = nil) -> Any {
        let copy = AIAbstractGameState(with: player)
        copy.exit = exit
        copy.inputs = inputs
        copy.outputs = outputs
        copy.escapable = escapable
        copy.player = player
        copy.interactableObjects = interactableObjects
        copy.setGameModel(self)
        return copy
    }

    /// Returns whether the current state is a winning state.
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let agent = player as? AIAbstractGamePlayer else { return false }
        return agent.position.distance(between: exit) < 64 && escapable
    }

    /// Returns an integer that scores the current state.
    func score(for player: GKGameModelPlayer) -> Int {
        guard let agent = player as? AIAbstractGamePlayer else { return -999 }
        return agent.playerId * Int.random(in: 1 ... 10)
    }
}
