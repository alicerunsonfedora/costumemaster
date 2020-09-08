//
//  GameAchievementTrigger.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/8/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// A class representation of a Game Center achievement trigger.
/// Game Center triggers will trigger earning an achievement upon player contact.
class GameAchievementTrigger: GameSignalSender {

    /// The achievement to earn when passing through the trigger.
    let gameAchievement: GameAchievement?

    /// Whether the trigger had been activated.
    var didActivate: Bool = false

    override var activeTexture: SKTexture {
        return SKTexture(imageNamed: "floor")
    }

    /// Initialize a Game Center trigger.
    /// - Parameter achievement: The game achievement to earn when passing through.
    /// - Parameter location: The level position of the trigger.
    init(with achievement: GameAchievement?, at location: CGPoint) {
        self.gameAchievement = achievement
        super.init(textureName: "floor", by: .activeByPlayerIntervention, at: location)
        self.kind = .trigger
        print(self.gameAchievement)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Whether the input should turn on/off based on player or object intervention.
    /// - Parameter player: The player to listen to for intervention.
    /// - Parameter objects: The objects to listen to for intervention.
    /// - Returns: Whether the input should activate given the intervention criteria.
    public override func shouldActivateOnIntervention(with player: Player?, objects: [SKSpriteNode?]) -> Bool {
        return player?.position.distance(between: self.position) ?? 0 < 64 && !self.didActivate
    }

    public override func onActivate(with event: NSEvent?, player: Player?) {
        self.didActivate = true
        if let achievementID = self.gameAchievement {
            GKAchievement.earn(with: achievementID)
        }
    }

    public override func onDeactivate(with event: NSEvent?, player: Player?) {

    }
}
