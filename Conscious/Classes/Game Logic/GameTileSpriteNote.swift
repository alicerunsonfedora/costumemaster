//
//  GameTileSpriteNote.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/5/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A special subclass of a sprite node that contains a special field for matrix positioning.
public class GameTileSpriteNode: SKSpriteNode {

    /// The world position of this node.
    var worldPosition: CGPoint = .zero

}
