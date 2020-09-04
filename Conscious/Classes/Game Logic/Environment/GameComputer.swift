//
//  GameComputer.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/4/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

class GameComputer: GameSignalSender {

    init(at position: CGPoint, with softwareLock: Bool) {
        super.init(textureName: "computer_wallup\(softwareLock ? "_alt": "")", by: .activeOncePermanently, at: position)
        self.kind = softwareLock ? .computerT1 : .computerT2
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }

    override func activate(with event: NSEvent?, player: Player?, objects: [SKSpriteNode?]) {
        super.activate(with: event, player: player)
        if AppDelegate.preferences.playComputerSound {
            self.run(SKAction.playSoundFileNamed("computerPowerOn", waitForCompletion: true))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
