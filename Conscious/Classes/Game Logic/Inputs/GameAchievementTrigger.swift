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
import GameKit
import SpriteKit

/// A class representation of a Game Center achievement trigger.
/// Game Center triggers will trigger earning an achievement upon player contact.
class GameAchievementTrigger: GameSignalSender {
    /// The achievement to earn when passing through the trigger.
    let gameAchievement: GameAchievement?

    /// Whether the trigger had been activated.
    var didActivate: Bool = false

    /// The active texture for the trigger.
    override var activeTexture: SKTexture {
        SKTexture(imageNamed: "floor")
    }

    /// Initialize a Game Center trigger.
    /// - Parameter achievement: The game achievement to earn when passing through.
    /// - Parameter location: The level position of the trigger.
    init(with achievement: GameAchievement?, at location: CGPoint) {
        gameAchievement = achievement
        super.init(textureName: "floor", by: [.activeByPlayerIntervention], at: location)
        kind = .trigger
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Whether the input should turn on/off based on player or object intervention.
    /// - Parameter player: The player to listen to for intervention.
    /// - Parameter objects: The objects to listen to for intervention.
    /// - Returns: Whether the input should activate given the intervention criteria.
    override public func shouldActivateOnIntervention(with player: Player?, objects _: [SKSpriteNode?]) -> Bool {
        player?.position.distance(between: position) ?? 0 < 64 && !didActivate
    }

    /// Activate an achievement when entering the field.
    override public func onActivate(with _: NSEvent?, player _: Player?) {
        didActivate = true
        if let achievementID = gameAchievement {
            GKAchievement.earn(with: achievementID)
        }
    }

    override public func onDeactivate(with _: NSEvent?, player _: Player?) {}
}
