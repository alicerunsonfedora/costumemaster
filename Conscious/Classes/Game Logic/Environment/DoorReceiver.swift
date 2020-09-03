//
//  LevelExitDoor.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A class that represents a door. This is commonly used for exit doors, but can be adapted to use any door.
public class DoorReceiver: SKSpriteNode, GameSignalReceivable {

    // MARK: STORED PROPERTIES
    var defaultOn: Bool

    var activationMethod: GameSignalMethod

    var inputs: [GameSignalSender] {
        didSet {
            if reverseSignal {
                self.defaultOn.toggle()
            }
        }
    }

    var baseTextureName: String

    var playerListener: Player?

    var levelPosition: CGPoint

    private var reverseSignal: Bool = false

    // MARK: COMPUTED PROPERTIES
    var activeTexture: SKTexture {
        return SKTexture(imageNamed: baseTextureName + (self.active ? "_on" : "_off"))
    }

    var active: Bool {
        switch activationMethod {
        case .allInputs:
            return !inputs.map { (input: GameSignalSender) in input.active }.contains(false) || self.defaultOn
        case .anyInput:
            return inputs.map { (input: GameSignalSender) in input.active }.contains(true) || self.defaultOn
        case .noInput:
            return true
        }
    }

    // MARK: CONSTRUCTORS
    required init(
        fromInput inputs: [GameSignalSender],
        reverseSignal: Bool,
        baseTexture: String,
        at location: CGPoint
    ) {
        self.defaultOn = reverseSignal
        self.inputs = inputs
        self.baseTextureName = baseTexture
        self.activationMethod = .allInputs
        self.levelPosition = location

        self.reverseSignal = reverseSignal
        if reverseSignal { self.defaultOn.toggle() }

        super.init(
            texture: SKTexture(imageNamed: baseTexture + "_off"),
            color: .clear,
            size: SKTexture(imageNamed: baseTexture + "_off").size()
        )

        self.inputs.forEach { input in input.receiver = self }
        self.texture = self.activeTexture
        self.physicsBody = instantiatePhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: METHODS

    private func instantiatePhysicsBody() -> SKPhysicsBody {
        return getWallPhysicsBody(with: SKTexture(imageNamed: "wall_edge_physics_mask"))
    }

    func receive(with player: Player?, event: NSEvent?, handler: ((Any?) -> Void)) {
        if let position = player?.position {
            if position.distance(between: self.position) < (self.texture?.size().width ?? 1) / 4 {
                handler(nil)
            }
        }
    }

    func update() {
        self.texture = self.activeTexture
    }

    func updateInputs() {
        for input in self.inputs {
            input.receiver = self
        }
    }

    /// Toggle the physics body for the door.
    /// - Note: This method should apply for all doors that are not exits.
    func togglePhysicsBody() {
        self.physicsBody = self.active ? nil : self.instantiatePhysicsBody()
    }

}
