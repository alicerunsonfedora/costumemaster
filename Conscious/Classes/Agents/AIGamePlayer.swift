//
//  AIGamePlayer.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// An abstract class that represents a game player.
class AIAbstractGamePlayer: NSObject, GKGameModelPlayer {

    /// The player's ID (required by GKGameModelPlayer).
    var playerId: Int = 0

    /// The player's position in the world.
    var position: CGPoint

    /// The current costume that the player is wearing.
    var currentCostume: PlayerCostumeType

    /// Whether the player has deployed a clone.
    var deployedClone: Bool = false

    /// Whether the player is carrying items.
    var carryingItems: Bool = false

    /// A list of the positions of objects that the player is carrying.
    var inventory: [CGPoint] = []

    /// A queue of the costumes the player can cycle through.
    private var costumeQueue: [PlayerCostumeType] = []

    /// Instantiate an abstract player.
    /// - Parameter position: The position of the player.
    /// - Parameter costumes: The list of costumes that the player can wear.
    init(at position: CGPoint, with costumes: [PlayerCostumeType]) {
        var cos = costumes
        var first: PlayerCostumeType = .default
        if !costumes.isEmpty {
            first = cos.removeFirst()
        }
        self.position = position
        self.currentCostume = first
        self.costumeQueue = cos
    }

    /// Switch to the next available costume.
    func nextCostume() {
        var costumes = costumeQueue + [currentCostume]
        self.currentCostume = costumes.removeFirst()
        self.costumeQueue = costumes
    }

    /// Switch to the previous available costume.
    func prevCostume() {
        var costumes = [currentCostume] + costumeQueue
        self.currentCostume = costumes.removeLast()
        self.costumeQueue = costumes
    }

}
