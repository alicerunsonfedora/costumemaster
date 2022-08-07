//
//  Animations.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// Get a list of frames from an atlas.
/// - Parameter atlas: The atlas to read animation frames from.
/// - Parameter reversable: Whether the animation should play in reverse afterwards. Defaults to false.
/// - Returns: A list of textures that make up the animation.
public func animated(fromAtlas atlas: SKTextureAtlas, reversable: Bool = false) -> [SKTexture] {
    var frames: [SKTexture] = []
    let useDoubles: Bool = atlas.textureNames.count > 9

    for iter in 0 ..< atlas.textureNames.count {
        let format = useDoubles && iter < 10 ? "0" : ""
        let name = "sprite_\(format)\(iter)"
        frames.append(atlas.textureNamed(name))
    }

    if reversable {
        frames += frames.reversed()
    }

    for frame in frames {
        frame.filteringMode = .nearest
    }

    return frames
}

public extension SKTextureAtlas {
    /// Convert this atlas to a list of animated frames.
    /// - Parameter reversable: Whether the animation should play in reverse afterwards. Defaults to false.
    /// - Returns: A list of textures that make up the animation.
    func toFrames(reversable: Bool = false) -> [SKTexture] {
        animated(fromAtlas: self, reversable: reversable)
    }
}
