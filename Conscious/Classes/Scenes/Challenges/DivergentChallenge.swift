//
//  DivergentChallenge.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/10/20.
//

import Foundation
import SpriteKit
import GameKit
import KeyboardShortcuts

/// The game scene specific to the level "Divergent".
class DivergentChallenge: ChallengeGameScene {

    /// Whether the player is eligible for receiving the achievement.
    var eligible: Bool = true

    /// Listen to the keys and disable the eligibility factor if a keypress for the costume change is active.
    override func keyDown(with event: NSEvent) {
        let keyCode = Int(event.keyCode)
        if keyCode == KeyboardShortcuts.getShortcut(for: .nextCostume)?.carbonKeyCode
            || keyCode == KeyboardShortcuts.getShortcut(for: .previousCostume)?.carbonKeyCode {
            self.eligible = false
        }
        super.keyDown(with: event)
    }

    /// Determine if the time to complete the level is less than 100 seconds and grant an achievement.
    override func willCalcuateChallengeResults() {
        if self.currentTime <= 100 && self.eligible {
            GKAchievement.earn(with: .overclocker)
        }
    }

}
