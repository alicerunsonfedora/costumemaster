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

class AIAbstractGamePlayer: NSObject, GKGameModelPlayer {

    var playerId: Int = 0
    var position: CGPoint
    var currentCostume: PlayerCostumeType
    var deployedClone: Bool = false
    var carryingItems: Bool = false

    init(at position: CGPoint, with costume: PlayerCostumeType) {
        self.position = position
        self.currentCostume = costume
    }

}
