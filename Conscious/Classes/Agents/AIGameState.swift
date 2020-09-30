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

class AIAbstractGameState: NSObject, GKGameModel {
    var players: [GKGameModelPlayer]? {
        return [player]
    }

    var activePlayer: GKGameModelPlayer? {
        return player
    }

    override var description: String {
        return "AIGameState(at exit: \(self.exit), inputs: \(self.inputs), outputs: \(self.outputs))"
    }

    var player: AIAbstractGamePlayer

    var exit: CGPoint = CGPoint.zero

    var escapable: Bool = false

    var inputs: [AIAbstractGameSignalSender] = []

    var outputs: [AIAbstractGameSignalReceivable] = []

    init(with player: AIAbstractGamePlayer) {
        self.player = player
    }

    func setGameModel(_ gameModel: GKGameModel) {
        guard let model = gameModel as? AIAbstractGameState else { return }
        self.exit = model.exit
        self.inputs = model.inputs
        self.outputs = model.outputs

        self.escapable = !model.inputs.filter { (input: AIAbstractGameSignalSender) in
            input.outputs.contains(self.exit)
        }.isEmpty

    }

    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves = [AIGameDecision]()
        for move in AIGamePlayerAction.allCases {
            moves.append(AIGameDecision(by: move, with: self.score(for: player)))
        }
        return moves
    }

    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let update = gameModelUpdate as? AIGameDecision else { return }
        switch update.action {
        case .moveUp, .moveDown:
            self.player.position.y += 64 * (update.action == .moveUp ? 1 : -1)
        case .moveLeft, .moveRight:
            self.player.position.x += 64 * (update.action == .moveRight ? 1 : -1)
        default:
            break
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AIAbstractGameState(with: self.player)
        copy.exit = self.exit
        copy.inputs = self.inputs
        copy.outputs = self.outputs
        copy.escapable = self.escapable
        copy.setGameModel(self)
        return copy
    }

    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let agent = player as? AIAbstractGamePlayer else { return false }
        return agent.position.distance(between: self.exit) < 64 && self.escapable
    }

    func score(for player: GKGameModelPlayer) -> Int {
        guard let agent = player as? AIAbstractGamePlayer else { return -999 }
        return Int.random(in: 1...10)
    }

}
