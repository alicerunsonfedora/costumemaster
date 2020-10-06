//
//  GameDeathPit.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/6/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A class that represents a death pit.
class GameDeathPit: GameTileSpriteNode {

    /// Whether the death pit sprite is based off of a texture.
    var trigger: Bool = false

    /// Determine whether the player should be killed.
    /// - Returns Whether the player should be killed, based on distance and costume.
    func shouldKill(_ player: Player?) -> Bool {
        guard let play = player else { return false }
        if player?.costume == .bird { return false }
        return play.position.distance(between: self.position) <= (self.trigger ? 64 : 56)
    }

}
