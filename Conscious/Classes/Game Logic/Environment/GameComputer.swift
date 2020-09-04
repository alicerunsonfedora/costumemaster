//
//  GameComputer.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/4/20.
//

import Foundation
import SpriteKit

class GameComputer: GameSignalSender {

    init(at position: CGPoint, with softwareLock: Bool) {
        super.init(textureName: "computer_wallup\(softwareLock ? "_alt": "")", by: .activeOncePermanently, at: position)
        self.kind = softwareLock ? .computerT1 : .computerT2
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
