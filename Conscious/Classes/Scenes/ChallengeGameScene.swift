//
//  ChallengeGameScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/10/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// An extended class of the game level scene dedicated to challenges.
///
/// Levels that use this subclass add extra components to track things such as steps taken, solution times,
/// and costume changes. The purpose of this subclass is to provide extensions to the level for challenges
/// for things such as achievements, leaderboards, and "advanced levels".
class ChallengeGameScene: GameScene {

    /// The current time in this level.
    public var currentTime: TimeInterval = 0.0

    /// The previous time interval.
    /// This is used to check when the currentTime should be updated.
    private var previousInterval: Int = 0

    /// Run the standard level game loop and update the challenge states as necessary.
    /// - Parameter currentTime: The current time when running the update.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let interval = Int(currentTime) % 60
        if interval > self.previousInterval
            || (interval == 0 && self.previousInterval != interval) {
            self.currentTime += 1
            self.previousInterval = interval
        }
    }

    /// Move to the next view and calculate the final challenge scores.
    ///
    /// Challenge scores are activated only when the player is near the exit and the exit is activated.
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        guard let playerPos = self.playerNode?.position else { return }
        if self.exitNode?.position.distance(between: playerPos) ?? 128 < 64 && self.exitNode?.active == true {
            self.willCalcuateChallengeResults()
        }
    }

    /// Run any challenge calculations after a given event.
    ///
    /// For levels with a time-based challenge, this method should be overridden to fit the appropriate
    /// calculations and grant any leaderboard status or achievement, respectively. This method will
    /// automatically trigger when the scene moves (`SKScene.willMove`) and should not be called
    /// directly.
    func willCalcuateChallengeResults() {
        print("Time to complete: \(self.currentTime) seconds")
    }

}
