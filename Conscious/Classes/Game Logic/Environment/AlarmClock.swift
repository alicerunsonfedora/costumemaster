//
//  AlarmClock.swift
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

class AlarmClock: GameSignalSender {
    
    init(with delay: Double = 3.0, at position: CGPoint) {
        super.init(textureName: "alarm_clock_wallup", by: .activeOnTimer, at: position)
        self.cooldown = delay
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
