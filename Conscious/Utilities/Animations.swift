//
//  Animations.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//

import Foundation
import SpriteKit

public func animated(fromAtlas atlas: SKTextureAtlas, reversable: Bool = false) -> [SKTexture] {
    var frames: [SKTexture] = []
    let useDoubles: Bool = atlas.textureNames.count > 9

    for iter in 0..<atlas.textureNames.count {
        let format = useDoubles && iter < 10 ? "0": ""
        let name = "sprite_\(format)\(iter)"
        frames.append(atlas.textureNamed(name))
    }

    for iter in 0..<atlas.textureNames.count {
        let format = useDoubles && iter < 10 ? "0": ""
        let name = "sprite_\(format)\(atlas.textureNames.count - 1 - iter)"
        frames.append(atlas.textureNamed(name))
    }

    return frames
}
