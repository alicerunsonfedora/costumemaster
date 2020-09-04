//
//  PressurePlate.swift
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

class GamePressurePlate: GameSignalSender {

    public init(at position: CGPoint) {
        super.init(textureName: "plate", by: .activeByPlayerIntervention, at: position)
        self.kind = .pressurePlate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func shouldActivateOnIntervention(with player: Player?, objects: [SKSpriteNode?]) -> Bool {
        if player?.position.distance(between: self.position) ?? 0 < 64 { return true }
        for object in objects where object?.physicsBody?.mass ?? 0 >= 50 {
            if object?.position.distance(between: self.position) ?? 0 < 64 { return true }
        }
        return false
    }

}
