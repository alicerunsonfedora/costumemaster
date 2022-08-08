//
//  Player.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Bunker
import CranberrySprite
import Foundation
import GameKit
import SpriteKit

/// A class representation of the game player.
///
/// The player class is a subclass of SKSpriteNode that contains additional logic for handling player changes such as
/// costume switching.
public class Player: SKSpriteNode {
    // MARK: STORED PROPERTIES

    /// Whether the player is being initialized.
    private var inInit: Bool = false

    /// Whether the player has made a static copy of itself.
    private var deployedCopy: Bool = false

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
    private var costumeQueue: Queue<PlayerCostumeType> = Queue()

    private var availableCostumes: [PlayerCostumeType] = []

    /// Whether the player is currently playing an animation.
    var animating: Bool = false

    /// Whether the player is changing costumes.
    var isChangingCostumes: Bool = false

    /// The heads-up display for the player.
    var hud: SKNode = .init()

    /// Whether to enable ML mode.
    var machine: Bool = false {
        didSet {
            if !animating {
                let property = costume.rawValue + (machine ? " ML" : "")
                texture = SKTexture(imageNamed: "Player (Idle, \(property))")
            }
        }
    }

    // MARK: COMPUTED PROPERTIES

    /// The SKTexture frames that play when a player is changing costumes.
    var changingFrames: [SKTexture] {
        let atlas = "Player_Change" + (machine ? "_ML" : "")
        return SKTextureAtlas(named: atlas).animated(reversible: true)
            .map { texture in
                texture.configureForPixelArt()
                return texture
            }
    }

    /// The walk cycle animation when moving south.
    var forwardWalkCycle: [SKTexture] {
        let property = costume.rawValue + (machine ? "_ML" : "")
        return SKTextureAtlas(named: "Player_Forward_\(property)").animated { iter in "sprite_\(iter)" }
            .map { texture in
                texture.configureForPixelArt()
                return texture
            }
    }

    /// The walk cycle animation when moving north.
    var backwardWalkCycle: [SKTexture] {
        let property = costume.rawValue + (machine ? "_ML" : "")
        return SKTextureAtlas(named: "Player_Backward_\(property)").animated { iter in "sprite_\(iter)" }
            .map { texture in
                texture.configureForPixelArt()
                return texture
            }
    }

    /// The walk cycle animation when moving north.
    var sidewardWalkCycle: [SKTexture] {
        let property = costume.rawValue + (machine ? "_ML" : "")
        return SKTextureAtlas(named: "Player_Side_\(property)").animated { iter in "sprite_\(iter)" }
            .map { texture in
                texture.configureForPixelArt()
                return texture
            }
    }

    /// The player's mass, accounting for the costume.
    private var mass: CGFloat {
        switch costume {
        case .default, .sorceress: return 9.05
        case .bird: return 8.75
        case .flashDrive: return 18.1
        }
    }

    /// Whether the player is carrying an object.
    public var isCarryingObject: Bool {
        !children.filter { child in child is GameHeavyObject }.isEmpty
    }

    /// The list of all available costumes for the player.
    public var costumes: [PlayerCostumeType] {
        availableCostumes
    }

    // MARK: CONSTRUCTOR

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter allowCostumes: A list of all of the allowed costumes for a particular level.
    public init(texture: SKTexture?, allowCostumes: [PlayerCostumeType]) {
        super.init(texture: texture, color: NSColor.clear, size: texture!.size())
        instantiatePhysicsBody(fromTexture: texture!)

        var costumes = allowCostumes
        availableCostumes = allowCostumes

        costume = costumes.remove(at: 0)
        costumeQueue = Queue()
        for costume in costumes {
            costumeQueue.enqueue(costume)
        }

        self.texture?.filteringMode = .nearest
        createHUD()
    }

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter allowCostumes: A list of all of the allowed costumes for a particular level.
    /// - Parameter costume: The costume the player starts with.
    public init(texture: SKTexture?, allowCostumes: [PlayerCostumeType], startingWith costume: PlayerCostumeType) {
        super.init(texture: texture, color: NSColor.clear, size: texture!.size())
        instantiatePhysicsBody(fromTexture: texture!)

        var costumes = [PlayerCostumeType]()
        let currentIndex = (allowCostumes.firstIndex(of: costume) ?? 0).clamp(lower: 0, upper: allowCostumes.count)

        costumes += allowCostumes[
            (currentIndex + 1).clamp(lower: currentIndex, upper: allowCostumes.count) ..< allowCostumes.count
        ]
        costumes += allowCostumes[0 ..< currentIndex]

        availableCostumes = allowCostumes
        self.costume = costume
        costumeQueue = Queue()
        for costume in costumes {
            costumeQueue.enqueue(costume)
        }

        let property = costume.rawValue + (machine ? " ML" : "")
        self.texture = SKTexture(imageNamed: "Player (Idle, \(property))")
        self.texture?.filteringMode = .nearest
        createHUD()
    }

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter color: The color of the sprite.
    /// - Parameter size: The size of the sprite.
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        instantiatePhysicsBody(fromTexture: texture ?? SKTexture(imageNamed: "Player (Idle, Default)"))
        self.texture?.filteringMode = .nearest
        zPosition = 10
        isHidden = false
        createHUD()
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
        switch id {
        case 0:
            return [PlayerCostumeType.flashDrive]
        case id where id < 3:
            return defaultSet[..<(id + 1)].map { costume in costume }
        default:
            return defaultSet
        }
    }

    // MARK: METHODS

    /// Instantiate this node's physics body.
    /// - Parameter fromTexture: The SKTexture to create the physics body from.
    private func instantiatePhysicsBody(fromTexture: SKTexture) {
        physicsBody = SKPhysicsBody(texture: fromTexture, size: fromTexture.size())
        physicsBody?.restitution = 0.05
        physicsBody?.friction = 0.2
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.mass = mass
    }

    /// Animate a costume change.
    /// - Parameter costume: The costume that the player is currently wearing or will switch from.
    private func animateCostumeChange(startingWith costume: PlayerCostumeType) {
        // Halt the player's movement.
        halt()
        isChangingCostumes = true

        // Create a ghost sprite for animation purposes.
        let ghostProperty = costume.rawValue + (machine ? " ML" : "")
        let ghostSprite = SKSpriteNode(
            texture: SKTexture(imageNamed: "Player (Idle, \(ghostProperty))"),
            size: size
        )
        ghostSprite.name = "ghost"
        ghostSprite.position = position
        ghostSprite.zPosition = zPosition - 1
        ghostSprite.isHidden = false
        ghostSprite.texture?.filteringMode = .nearest
        parent?.addChild(ghostSprite)

        // Play the animations and remove the ghost from the player's node heirarchy.
        animating = true
        let property = self.costume.rawValue + (machine ? " ML" : "")
        runSequence {
            SKAction.run {
                ghostSprite.runSequence {
                    SKAction.wait(forDuration: Double(self.changingFrames.count) / 2 / 10)
                    SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(property))"))
                    SKAction.wait(forDuration: Double(self.changingFrames.count) / 0.61 / 10)
                }
            }
            SKAction.run {
                if UserDefaults.playChangeSound {
                    self.run(SKAction.playSoundFileNamed("changeCostume", waitForCompletion: false))
                }
            }
            SKAction.animate(with: changingFrames, timePerFrame: 0.1, resize: false, restore: false)
            SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(property))"))
            SKAction.run { self.texture?.filteringMode = .nearest }
            SKAction.run { self.isChangingCostumes = false }
            SKAction.run { ghostSprite.removeFromParent() }
        }

        animating = false
        physicsBody?.mass = mass
    }

    // MARK: COSTUME CHANGE METHODS

    /// Switch to the previous costume.
    /// - Returns: The previous costume the player is now wearing.
    public func previousCostume() -> PlayerCostumeType {
        if costumeQueue.isEmpty {
            run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: true))
            return costume
        }

        // Don't initiate another change if we're already changing costumes.
        if isChangingCostumes { return costume }

        // Re-order the queue.
        let currentCostume = costume
        let newCostume = costumeQueue.last

        costumeQueue.enqueue(currentCostume)
        while costumeQueue.first != newCostume {
            costumeQueue.enqueue(costumeQueue.dequeue() ?? .default)
        }

        costume = costumeQueue.dequeue() ?? .default

        // Start animating costume changes.
        animateCostumeChange(startingWith: currentCostume)

        // Check for any achievements with Game Center.
        checkAchievementStatus()

        // Return the costume type.
        return costume
    }

    /// Switch to the next available costume.
    /// - Returns: The next costume the player has switched to.
    public func nextCostume() -> PlayerCostumeType {
        if costumeQueue.isEmpty {
            run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: true))
            return costume
        }

        // Don't initiate another change if we're already changing costumes.
        if isChangingCostumes { return costume }

        // Re-order the queue.
        let currentCostume = costume
        costume = costumeQueue.dequeue() ?? .default
        costumeQueue.enqueue(currentCostume)

        // Start animating costume changes.
        animateCostumeChange(startingWith: currentCostume)

        // Check for any achievements with Game Center.
        checkAchievementStatus()

        // Return the costume type.
        return costume
    }

    /// Remove a costume from the costume queue.
    /// - Parameter costume: The costume to remove from the queue.
    func remove(costume: PlayerCostumeType) {
        while costumeQueue.first != costume {
            costumeQueue.enqueue(costumeQueue.dequeue() ?? .default)
        }
        _ = costumeQueue.dequeue()
    }

    /// Check the current  ostume increments and determine whether to grant an achievement.
    private func checkAchievementStatus() {
        switch costume {
        case .bird:
            switch GameStore.shared.costumeIncrementBird {
            case 1:
                GKAchievement.earn(with: .newBird)
                GKAchievement.updateProgress(on: .quickfooted, to: 1.0)
            case let count where count < 100:
                GKAchievement.updateProgress(on: .quickfooted, to: Double(count))
            case 100:
                GKAchievement.earn(with: .quickfooted)
            default:
                break
            }
        case .sorceress where GameStore.shared.costumeIncrementSorceress == 1:
            GKAchievement.earn(with: .newSorceress)
        default:
            break
        }
    }

    /// Update the player's data.
    public func update() {
        if let parentNodes = parent?.children {
            for child in parentNodes where child.name == "ghost" && !isChangingCostumes {
                child.removeFromParent()
            }
        }
        updateHUD()
    }

    // MARK: HUD

    /// Create the heads-up display.
    private func createHUD() {
        let scale = size.width / 4
        let hud = SKNode(); hud.zPosition = 100; hud.name = "HUD"

        let carrying = SKSpriteNode(imageNamed: "hud_object_carry")
        carrying.position = CGPoint(x: position.x - scale, y: position.y + scale)
        carrying.texture?.filteringMode = .nearest
        carrying.name = "object"

        let usbIndicator = SKSpriteNode(imageNamed: "hud_cost_usb")
        usbIndicator.position = CGPoint(x: position.x + scale, y: position.y + scale)
        usbIndicator.texture?.filteringMode = .nearest
        usbIndicator.name = "costume_usb"
        usbIndicator.setScale(0.75)

        let birdIndicator = SKSpriteNode(imageNamed: "hud_cost_bird")
        birdIndicator.position = CGPoint(x: position.x + scale, y: usbIndicator.position.y - 20)
        birdIndicator.texture?.filteringMode = .nearest
        birdIndicator.name = "costume_bird"
        birdIndicator.setScale(0.75)

        let sorceressIndicator = SKSpriteNode(imageNamed: "hud_cost_sorceress")
        sorceressIndicator.position = CGPoint(x: position.x + scale, y: birdIndicator.position.y - 20)
        sorceressIndicator.texture?.filteringMode = .nearest
        sorceressIndicator.name = "costume_sorceress"
        sorceressIndicator.setScale(0.75)

        [carrying, usbIndicator, birdIndicator, sorceressIndicator].forEach { child in hud.addChild(child) }

        self.hud = hud
        addChild(self.hud)
    }

    /// Update the heads-up display.
    private func updateHUD() {
        hud.childNode(withName: "object")?.alpha = isCarryingObject ? 1.0 : 0.0
        hud.childNode(withName: "costume_usb")?.alpha = getAlphaOfCostumeHUD(for: .flashDrive)
        hud.childNode(withName: "costume_bird")?.alpha = getAlphaOfCostumeHUD(for: .bird)
        hud.childNode(withName: "costume_sorceress")?.alpha = getAlphaOfCostumeHUD(for: .sorceress)
    }

    /// Get the alpha value for the cosume HUD element.
    /// - Parameter value: The costume to get the alpha value for.
    /// - Returns: A cloat value for the alpha of this node.
    private func getAlphaOfCostumeHUD(for value: PlayerCostumeType) -> CGFloat {
        if !availableCostumes.contains(value) { return 0.0 }
        if !(costume == value) { return 0.65 }
        return 1.0
    }

    // MARK: MOVEMENT METHODS

    /// Move the player by a specific amount and adjust the velocity repsectively.
    ///
    /// Use this when needing to apply an impulse directly on the player to cause a movement to occur. In other
    /// instances, using `move(_ direction: PlayerMoveDirection, unit: CGSize)` is preferred.
    /// Additionally, this method does not handle the proper animation to play when moving in a direction.
    ///
    /// - Parameter delta: A vector that represents the delta to move by.
    public func move(_ delta: CGVector) {
        guard UserDefaults.usePhysicsMovement else {
            run(SKAction.move(by: delta, duration: 4.0))
            return
        }

        physicsBody?.applyImpulse(delta)

        guard var velocity = physicsBody?.velocity else { return }
        let maxSpeed: Float = 1.4
        velocity.dx = CGFloat(Float(velocity.dx).clamp(to: (-1 * maxSpeed) ..< maxSpeed))
        velocity.dy = CGFloat(Float(velocity.dy).clamp(to: (-1 * maxSpeed) ..< maxSpeed))
    }

    /// Stop the player from moving and remove all current animations.
    public func halt() {
        if physicsBody?.velocity != .zero { physicsBody?.velocity = .zero }
        removeAllActions()
        animating = false
        if xScale < 0 { xScale *= -1 }
        if hud.xScale < 0 { hud.xScale *= -1 }
        let property = costume.rawValue + (machine ? " ML" : "")
        run(SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(property))")))
    }

    /// Make a copy of the player's sprite body in the map.
    public func copyAsObject() {
        guard let parent = parent as? GameScene else { return }
        if deployedCopy {
            for child in parent.children where child.name == "playerCopy" && child is GameHeavyObject {
                child.removeFromParent()
            }
            parent.interactables.removeAll { child in child.name == "playerCopy" }
        } else {
            if costume != .flashDrive { return }
            let copy = GameHeavyObject(with: "USB Clone", at: CGPoint(x: 0, y: 0))
            copy.name = "playerCopy"
            copy.position = CGPoint(x: position.x - 32, y: position.y)
            copy.canBeCarried = false
            parent.addChild(copy)
            parent.interactables.append(copy)
        }
        deployedCopy.toggle()
    }
}
