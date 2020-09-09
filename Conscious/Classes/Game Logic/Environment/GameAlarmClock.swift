//
//  GameAlarmClock.swift
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

/// A class representation of an alarm clock (timer).
class GameAlarmClock: GameSignalSender {

    /// Initialze an alarm clock.
    /// - Parameter delay: The number of seconds it takes for the alarm clock to turn off.
    /// - Parameter position: The world matrix position of the alarm clock.
    init(with delay: Double = 3.0, at position: CGPoint) {
        super.init(textureName: "alarm_clock_wallup", by: .activeOnTimer, at: position)
        self.cooldown = delay
        self.kind = .alarmClock
        self.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
    }

    override func onActivate(with event: NSEvent?, player: Player?) {
        if AppDelegate.preferences.playAlarmSound {
            self.run(SKAction.playSoundFileNamed("alarmEnable", waitForCompletion: true))
        }
    }

    /// Play the alarm when deactivated.
    override func onDeactivate(with event: NSEvent?, player: Player?) {
        if AppDelegate.preferences.playAlarmSound {
            self.run(
                SKAction.repeat(SKAction.playSoundFileNamed("alarmDisable", waitForCompletion: true), count: 2)
            )
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
