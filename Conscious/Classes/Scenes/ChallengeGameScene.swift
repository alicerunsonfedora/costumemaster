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

    /// The current costume known to this scene.
    private var cachedCostume: PlayerCostumeType = .flashDrive

    /// A tuple of integers containing the number of times a player has switched costumes.
    ///
    /// The tuple is in the order: USB, Bird, Sorceress. The "default" costume is excluded.
    public var costumeIncrements: (Int, Int, Int) = (0, 0, 0)
    // swiftlint:disable:previous large_tuple

    /// The total number of times a player has switched costumes.
    public var totalCostumeIncrement: Int = 0

    /// Set up the scene and set the cached costume.
    override func sceneDidLoad() {
        super.sceneDidLoad()
        if let costume = self.playerNode?.costume {
            self.cachedCostume = costume
        }
    }

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

        if self.playerNode?.costume != self.cachedCostume {
            var (usb, bird, sorceress) = self.costumeIncrements
            switch self.playerNode?.costume {
            case .bird:
                bird += 1
            case .flashDrive:
                usb += 1
            case .sorceress:
                sorceress += 1
            default:
                break
            }
            self.costumeIncrements = (usb, bird, sorceress)
            self.cachedCostume = self.playerNode?.costume ?? .default
            self.totalCostumeIncrement += 1
        }
    }

    /// Move to the next view and calculate the final challenge scores.
    ///
    /// Challenge scores are activated only when the player is near the exit and the exit is activated.
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        guard let playerPos = self.playerNode?.position else { return }
        if self.exitNode?.position.distance(between: playerPos) ?? 128 < 64 && self.exitNode?.active == true {
            self.willCalculateChallengeResults()
        }
    }

    /// Run any challenge calculations after a given event.
    ///
    /// For levels with a time-based challenge, this method should be overridden to fit the appropriate
    /// calculations and grant any leaderboard status or achievement, respectively.
    ///
    /// For levels with a costume-dependent challenge (i.e., least amount of switches), this method
    /// should be overridden to account for these calculations.
    ///
    /// - Important: This method will automatically trigger when the scene moves (`SKScene.willMove`)
    /// and should not be called directly.
    func willCalculateChallengeResults() {
        let (usb, bird, sorceress) = self.costumeIncrements
        print("Time to complete: \(self.currentTime) seconds")
        print("Total costume changes: \(self.totalCostumeIncrement)")
        print("Costume changes: USB - \(usb), Bird - \(bird), Sorceress - \(sorceress)")
    }

    /// Send a Game Center notification to the player to show them their time scores.
    ///
    /// This method should most likely be called in `ChallengeGameScene.willCalculateChallengeResults` for maps
    /// with a timed leaderboard.
    func announceTimeResults() {
        if !GKLocalPlayer.local.isAuthenticated { return }
        GKNotificationBanner
            .show(
                withTitle: "Great work!",
                message: "You finished \(self.name ?? "Level") in \(self.currentTime) seconds."
            ) { }
    }

}
