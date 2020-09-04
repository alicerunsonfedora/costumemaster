//
//  GameLever.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/4/20.
//

import Foundation
import SpriteKit

class GameLever: GameSignalSender {

    init(at position: CGPoint) {
        super.init(textureName: "lever_wallup", by: .activeOncePermanently, at: position)
        self.kind = .lever
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
