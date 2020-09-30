//
//  AIGameScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameplayKit

class AIGameScene: ChallengeGameScene {

    override func sceneDidLoad() {
        super.sceneDidLoad()
        let initialState = self.getState()
        print(initialState)
    }

    func blockInput() {
        print("Keyboard input is blocked in an AI game scene.")
        NSSound.beep()
    }

    override func keyDown(with event: NSEvent) {
        blockInput()
    }

    func getState() -> AIAbstractGameState? {
        guard let player = playerNode else { return nil }
        let state = AIAbstractGameState(with: AIAbstractGamePlayer(at: player.position, with: player.costume))
        state.exit = self.exitNode?.position ?? CGPoint.zero

        var signals = [AIAbstractGameSignalSender]()
        for input in self.switches {
            var signal = AIAbstractGameSignalSender(
                position: input.position,
                active: input.active,
                outputs: input.receivers.map { out in out.position }
            )
            signal.timer = Int(input.cooldown)
            signals.append(signal)
        }

        var receivers = [AIAbstractGameSignalReceivable]()
        for output in self.receivers {
            receivers.append(
                AIAbstractGameSignalReceivable(active: output.active, location: output.position)
            )
        }

        state.inputs = signals
        state.outputs = receivers
        state.escapable = self.exitNode?.active ?? false

        return state
    }

    func setState(_ state: AIGameDecision) {

    }

}
