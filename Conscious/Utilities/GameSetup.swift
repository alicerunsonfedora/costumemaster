//
//  GameSetup.swift
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

/// Get the type of tile from a given definition.
/// - Parameter tile: The tile definition to look up the type for.
/// - Returns: The respective tile type as `GameTileType`.
public func getTileType(fromDefinition tile: SKTileDefinition) -> GameTileType {
    // swiftlint:disable:previous cyclomatic_complexity
    // This will inevitably cause cyclomatic complexity, but this is the best way as of right now to determine the type
    // of tile we're working with.
    guard let name = tile.name else { return .unknown }
    switch name {
    case name where name.starts(with: "wall"):
        return .wall
    case name where name.starts(with: "door"):
        return .door
    case name where name.starts(with: "lever"):
        return .lever
    case name where name.starts(with: "computer") && name.contains("_T1"):
        return .computerT1
    case name where name.starts(with: "computer") && name.contains("_T2"):
        return .computerT2
    case name where name.contains("_ho"):
        return .heavyObject
    case "trigger_gc":
        return .triggerGameCenter
    case "trigger_kill":
        return .triggerKill
    case name where name.starts(with: "death_pit"):
        return .deathPit
    case name where name.starts(with: "floor"):
        return .floor
    case name where name.starts(with: "alarm_clock"):
        return .alarmClock
    case name where name.starts(with: "plate"):
        return .pressurePlate
    case name where name.starts(with: "iris_scanner"):
        return .biometricScanner
    case "Main":
        return .player
    default:
        return .unknown
    }
}

/// Create a physics body for a wall with a given texture.
/// - Parameter texture: The texture to assign the wall's physics body to.
/// - Returns: A physics body that matches the texture.
public func getWallPhysicsBody(with texture: SKTexture) -> SKPhysicsBody {
    let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
    physicsBody.restitution = 0
    physicsBody.linearDamping = 1000
    physicsBody.friction = 0.7
    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = false
    physicsBody.isResting = true
    physicsBody.allowsRotation = false
    physicsBody.pinned = true
    return physicsBody
}

/// Create a physics body for a wall with a given texture.
/// - Parameter texture: The texture to assign the wall's physics body to.
/// - Returns: A physics body that matches the texture.
public func getWallPhysicsBody(with textureName: String) -> SKPhysicsBody {
    getWallPhysicsBody(with: SKTexture(imageNamed: textureName))
}

/// Create a physics body for a heavy object with a given texture.
/// - Parameter texture: The texture to assign the object's physics body to.
/// - Returns: A physics body that matches the texture.
public func getHeavyObjectPhysicsBody(with texture: SKTexture) -> SKPhysicsBody {
    let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
    physicsBody.mass = 100
    physicsBody.linearDamping = 50
    physicsBody.friction = 1.0
    physicsBody.isDynamic = true
    physicsBody.isResting = true
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    return physicsBody
}

/// Create a physics body for a heavy object with a given texture.
/// - Parameter texture: The name of the texture to assign the object's physics body to.
/// - Returns: A physics body that matches the texture.
public func getHeavyObjectPhysicsBody(with textureName: String) -> SKPhysicsBody {
    getHeavyObjectPhysicsBody(with: SKTexture(imageNamed: textureName))
}
