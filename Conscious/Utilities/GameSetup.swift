//
//  GameSetup.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//

import Foundation
import SpriteKit

/// Get the type of tile from a given definition.
/// - Parameter tile: The tile definition to look up the type for.
/// - Returns: The respective tile type as `GameTileType`.
public func getTileType(fromDefinition tile: SKTileDefinition) -> GameTileType {
    if let name = tile.name {
        switch name {
        case name where name.starts(with: "wall"):
            return .wall
        case name where name.starts(with: "exit"):
            return .exit
        case "Main":
            return .player
        default:
            return .unknown
        }
//        if name.starts(with: "wall") { return .wall }
//        if name == "Main" { return .player }
//        if name.starts(with: "exit") { return .exit }
    }
    return .unknown
}

/// Create a physics body for a wall with a given texture.
/// - Parameter texture: The texture to assign the wall's physics body to.
public func getWallPhysicsBody(with texture: SKTexture) -> SKPhysicsBody {
    let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
    physicsBody.restitution = 0
    physicsBody.linearDamping = 1000
    physicsBody.friction = 0.7
    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = false
    physicsBody.isResting = true
    physicsBody.allowsRotation = false
    return physicsBody
}
