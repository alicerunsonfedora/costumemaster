//
//  SeededChallenge.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameKit
import KeyboardShortcuts
import SpriteKit

/// The challenge scene for the level "Seeded".
class SeededChallenge: CostumemasteryInheritable {
    /// Whether the player has earned the achievement for this room.
    private var eligible: Bool = false

    /// Submit the latest time to the leaderboards.
    override func willCalculateChallengeResults() {
        super.willCalculateChallengeResults()
        GKLeaderboard.submit(to: .seededDaily, with: Int(currentTime))
        announceTimeResults()
    }

    /// Perform the key down events and earn the "Cut and Paste" achievement if not earned already.
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        if !eligible, Int(event.keyCode) == KeyboardShortcuts.getShortcut(for: .copy)?.carbonKeyCode {
            GKAchievement.earn(with: .cloned)
            eligible = true
        }
    }
}
