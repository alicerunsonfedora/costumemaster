//
//  GameLever.swift
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

class GameLever: GameSignalSender {

    init(at position: CGPoint) {
        super.init(textureName: "lever_wallup", by: .activeOncePermanently, at: position)
        self.kind = .lever
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }

    override func activate(with event: NSEvent?, player: Player?, objects: [SKSpriteNode?]) {
        super.activate(with: event, player: player)
        if AppDelegate.preferences.playLeverSound {
            self.run(SKAction.playSoundFileNamed("leverToggle", waitForCompletion: true))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
