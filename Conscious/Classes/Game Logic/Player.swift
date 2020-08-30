//
//  Player.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
//

import Foundation
import SpriteKit
import GameKit

/// A class representation of the game player.
///
/// The player class is a subclass of SKSpriteNode that contains additional logic for handling player changes such as
/// costume switching.
public class Player: SKSpriteNode {

    // MARK: STORED PROPERTIES

    /// Whether the player is being initialized.
    private var inInit: Bool = false

    /// Thre current costume the player is wearing.
    public var costume: PlayerCostumeType = .flashDrive {
        didSet {
            if !inInit {
                switch costume {
                case .flashDrive:
                    GameStore.shared.costumeIncrementUSB += 1
                case .bird:
                    GameStore.shared.costumeIncrementBird += 1
                case .sorceress:
                    GameStore.shared.costumeIncrementSorceress += 1
                default:
                    break
                }
            }
        }
    }

    /// A queue of all available costumes the player can switch to.
    private var costumeQueue: [PlayerCostumeType] = [.bird, .sorceress, .default]

    /// Whether the player is currently playing an animation.
    private var animating: Bool = false

    /// Whether the player is changing costumes.
    private var isChangingCostumes: Bool = false

    // MARK: COMPUTED PROPERTIES

    /// The SKTexture frames that play when a player is changing costumes.
    private var changingFrames: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Change"), reversable: true)
    }

    /// The walk cycle animation when moving south.
    private var forwardWalkCycle: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Forward_\(self.costume.rawValue)"))
    }

    /// The walk cycle animation when moving north.
    private var backwardWalkCycle: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Backward_\(self.costume.rawValue)"))
    }

    /// The walk cycle animation when moving north.
    private var sidewardWalkCycle: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Side_\(self.costume.rawValue)"))
    }

    /// The player's mass, accounting for the costume.
    private var mass: CGFloat {
        switch self.costume {
        case .default, .sorceress:
            return 9.05
        case .bird:
            return 8.95
        case .flashDrive:
            return 18.1
        }
    }

    // MARK: CONSTRUCTOR

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter allowCostumes: A list of all of the allowed costumes for a particular level.
    public init(texture: SKTexture?, allowCostumes: [PlayerCostumeType]) {
        super.init(texture: texture, color: NSColor.clear, size: texture!.size())
        self.instantiatePhysicsBody(fromTexture: texture!)

        var costumes = allowCostumes
        self.costume = costumes.remove(at: 0)
        self.costumeQueue = costumes
        self.texture?.filteringMode = .nearest
    }

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter allowCostumes: A list of all of the allowed costumes for a particular level.
    /// - Parameter costume: The costume the player starts with.
    public init(texture: SKTexture?, allowCostumes: [PlayerCostumeType], startingWith costume: PlayerCostumeType) {
        super.init(texture: texture, color: NSColor.clear, size: texture!.size())
        self.instantiatePhysicsBody(fromTexture: texture!)

        var costumes = allowCostumes
        costumes.removeAll(where: { cost in cost == costume })
        self.costume = costume
        self.costumeQueue = costumes
        self.texture = SKTexture(imageNamed: "Player (Idle, \(costume.rawValue))")
        self.texture?.filteringMode = .nearest
    }

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter color: The color of the sprite.
    /// - Parameter size: The size of the sprite.
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.instantiatePhysicsBody(fromTexture: texture!)
        self.texture?.filteringMode = .nearest
        self.zPosition = 10
        self.isHidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: STATIC METHODS

    /// Get the list of costumes from a given ID.
    /// - Parameter id: An integer representing the ID of costumes available.
    /// - Note: In most cases, IDs will range from 0-2, 0 being the default scenario (flash drive), and 2 being all
    /// available costumes (flash drive, bird, and sorceress). In cases where a player can take off a costume,
    /// use ID 3.
    public static func getCostumeSet(id: Int) -> [PlayerCostumeType] {
        // swiftlint:disable:previous identifier_name
        let defaultSet: [PlayerCostumeType] = [.flashDrive, .bird, .sorceress, .default]
        if id == 0 {
            return [PlayerCostumeType.flashDrive]
        } else {
            let upperBound = id + 1
            return defaultSet[..<upperBound].map { costume in costume }
        }
    }

    // MARK: METHODS

    /// Instantiate this node's physics body.
    /// - Parameter fromTexture: The SKTexture to create the physics body from.
    private func instantiatePhysicsBody(fromTexture: SKTexture) {
        self.physicsBody = SKPhysicsBody(texture: fromTexture, size: fromTexture.size())
        self.physicsBody?.restitution = 0.05
        self.physicsBody?.friction = 0.2
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = self.mass
    }

    /// Animate a costume change.
    /// - Parameter costume: The costume that the player is currently wearing or will switch from.
    private func animateCostumeChange(startingWith costume: PlayerCostumeType) {
        // Halt the player's movement.
        self.halt()
        self.isChangingCostumes = true

        // Create a ghost sprite for animation purposes.
        let ghostSprite = SKSpriteNode(
            texture: SKTexture(imageNamed: "Player (Idle, \(costume.rawValue))"),
            size: self.size
        )
        ghostSprite.name = "ghost"
        ghostSprite.position = self.position
        ghostSprite.zPosition = self.zPosition - 1
        ghostSprite.isHidden = false
        ghostSprite.texture?.filteringMode = .nearest
        self.parent?.addChild(ghostSprite)

        // Play the animations and remove the ghost from the player's node heirarchy.
        self.animating = true
        self.run(SKAction.sequence([
            SKAction.run {
                ghostSprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: Double(self.changingFrames.count) / 2 / 10),
                    SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")),
                    SKAction.wait(forDuration: Double(self.changingFrames.count) / 0.61 / 10)
                ])
            )},
            SKAction.run {
                if AppDelegate.preferences.playChangeSound {
                    self.run(SKAction.playSoundFileNamed("changeCostume", waitForCompletion: false))
                }
            },
            SKAction.animate(with: self.changingFrames, timePerFrame: 0.1, resize: false, restore: false),
            SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")),
            SKAction.run {  self.texture?.filteringMode = .nearest },
            SKAction.run { ghostSprite.removeFromParent(); self.removeAllChildren() }
        ]))
        self.animating = false
        self.isChangingCostumes = false
        self.physicsBody?.mass = self.mass
    }

    /// Switch to the previous costume.
    /// - Returns: The previous costume the player is now wearing.
    public func previousCostume() -> PlayerCostumeType {
        if self.costumeQueue.isEmpty { return self.costume }

        // Don't initiate another change if we're already changing costumes.
        if self.isChangingCostumes { return self.costume }

        // Re-order the queue.
        let currentCostume = self.costume
        self.costume = self.costumeQueue.popLast() ?? .default
        self.costumeQueue.insert(currentCostume, at: 0)

        // Start animating costume changes.
        self.animateCostumeChange(startingWith: currentCostume)

        // Check for any achievements with Game Center.
        self.checkAchievementStatus()

        // Return the costume type.
        return self.costume
    }

    /// Switch to the next available costume.
    /// - Returns: The next costume the player has switched to.
    public func nextCostume() -> PlayerCostumeType {
        if self.costumeQueue.isEmpty { return self.costume }

        // Don't initiate another change if we're already changing costumes.
        if self.isChangingCostumes { return self.costume }

        // Re-order the queue.
        let currentCostume = self.costume
        self.costume = self.costumeQueue.remove(at: 0)
        self.costumeQueue.append(currentCostume)

        // Start animating costume changes.
        self.animateCostumeChange(startingWith: currentCostume)

        // Check for any achievements with Game Center.
        self.checkAchievementStatus()

        // Return the costume type.
        return self.costume
    }

    /// Check the current  ostume increments and determine whether to grant an achievement.
    private func checkAchievementStatus() {
        switch self.costume {
        case .flashDrive:
            break
        case .bird:
            if GameStore.shared.costumeIncrementBird == 1 {
                GKAchievement.earn(with: .newBird)
            }
        case .sorceress:
            if GameStore.shared.costumeIncrementSorceress == 1 {
                GKAchievement.earn(with: .newSorceress)
            }
        case .default:
            GKAchievement.earn(with: .endReveal)
        }
    }

    // MARK: MOVEMENT METHODS

    /// Move the player by a specific amount.
    ///
    /// Use this when needing to apply an impulse directly on the player to cause a movement to occur. In other
    /// instances, using `move(_ direction: PlayerMoveDirection, unit: CGSize)` is preferred.
    /// Additionally, this method does not handle the proper animation to play when moving in a direction.
    ///
    /// - Parameter delta: A vector that represents the delta to move by.
    public func move(_ delta: CGVector) {
        var newDelta = delta
        let maximumNegativeVelocity = CGVector(dx: -1.4, dy: -1.4)
        let maximumPositiveVelocity = CGVector(dx: 1.4, dy: 1.4)
        if newDelta < maximumNegativeVelocity {
            newDelta = CGVector(dx: newDelta.dx + 1.4, dy: newDelta.dy + 1.4)
        } else if newDelta > maximumPositiveVelocity {
            newDelta = CGVector(dx: newDelta.dy - (newDelta.dx - 1.4), dy: newDelta.dy - (newDelta.dx - 1.4))
        }
        self.physicsBody?.applyImpulse(newDelta)
    }

    /// Stop the player from moving and remove all current animations.
    public func halt() {
        if self.physicsBody?.velocity != .zero { self.physicsBody?.velocity = .zero }
        self.removeAllActions()
        self.animating = false
        if self.xScale < 0 { self.xScale *= -1 }
        self.run(SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")))
    }

    /// Move the player in a given direction, relative to the size of the world.
    ///
    /// This method is typically preferred since AI agents can call this method instead of calculating the delta
    /// beforehand. This method also handles any animations that need to be added to make sure the player
    /// has an appropriate animation while walking.
    ///
    /// - Parameter direction: The direction the player will move in.
    /// - Parameter unit: The base unit to calculate the movement delta, relatively.
    public func move(_ direction: PlayerMoveDirection, unit: CGSize) {
        // Stop if we're changing costumes.
        if self.isChangingCostumes { return }

        // Create the delta vector and animation
        var delta = CGVector(dx: 0, dy: 0)
        var action: SKAction?

        // Calculate the correct delta based on the direction and generate the proper animation.
        switch direction {
        case .north:
            delta.dy += unit.height / 2
            action = SKAction.animate(
                with: self.backwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .south:
            delta.dy -= unit.height / 2
            action = SKAction.animate(
                with: self.forwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .east:
            delta.dx += unit.width / 2
            action = SKAction.animate(
                with: self.sidewardWalkCycle,
                timePerFrame: 0.25,
                resize: false,
                restore: true
            )
        case .west:
            delta.dx -= unit.width / 2
            action = SKAction.animate(
                with: self.sidewardWalkCycle,
                timePerFrame: 0.25,
                resize: false,
                restore: true
            )
        }

        // Call the move method with the new delta.
        self.move(delta)

        // If we found an animation, play it and set animating to true.
        if action != nil && !self.animating {
            self.run(SKAction.repeatForever(action!))
            if direction == .west {
                self.xScale *= -1
            }
            self.animating = true
        }

    }
}
