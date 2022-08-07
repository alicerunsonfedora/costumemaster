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
public class DoorReceiver: GameStructureObject, GameSignalReceivable {
    // MARK: STORED PROPERTIES

    /// Whether the door is on by default.
    var defaultOn: Bool

    /// The method of how this door will be activated.
    var activationMethod: GameSignalMethod

    /// The list of inputs that activate the door.
    var inputs: [GameSignalSender] {
        didSet {
            if reverseSignal {
                defaultOn.toggle()
            }
        }
    }

    /// The base texture name for the door.
    var baseTextureName: String

    /// The player listener for this door.
    var playerListener: Player?

    private var reverseSignal: Bool = false

    // MARK: COMPUTED PROPERTIES

    /// The activation-based texture for this door.
    var activeTexture: SKTexture {
        SKTexture(imageNamed: baseTextureName + (active ? "_on" : "_off"))
    }

    /// Whether the door is activated.
    var active: Bool {
        switch activationMethod {
        case .allInputs:
            return !inputs.map { (input: GameSignalSender) in input.active }.contains(false) || self.defaultOn
        case .anyInput:
            return !inputs.filter { (input: GameSignalSender) in input.active == true }.isEmpty || self.defaultOn
        case .inverseAllInputs:
            return !inputs.map { (input: GameSignalSender) in input.active }.contains(true) || !self.defaultOn
        default:
            return true
        }
    }

    /// The description for this class.
    override public var description: String {
        "\(self.className)(active: \(self.active), gate: \(self.activationMethod), " +
            "position: \(self.worldPosition))"
    }

    // MARK: CONSTRUCTORS

    required init(
        fromInput inputs: [GameSignalSender],
        reverseSignal: Bool,
        baseTexture: String,
        at location: CGPoint
    ) {
        defaultOn = reverseSignal
        self.inputs = inputs
        baseTextureName = baseTexture
        activationMethod = .allInputs

        self.reverseSignal = reverseSignal
        if reverseSignal { defaultOn.toggle() }

        super.init(
            with: SKTexture(imageNamed: baseTexture + "_off"),
            size: SKTexture(imageNamed: baseTexture + "_off").size()
        )

        worldPosition = location
        self.inputs.forEach { input in input.receivers.append(self) }
        texture = activeTexture
        instantiateBody(with: instantiatePhysicsBody())
        locked = false
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: METHODS

    /// Initialize the physics body for the door.
    private func instantiatePhysicsBody() -> SKPhysicsBody {
        getWallPhysicsBody(with: SKTexture(imageNamed: "wall_edge_physics_mask"))
    }

    /// Receive input from a player or event.
    func receive(with player: Player?, event _: NSEvent?, handler: (Any?) -> Void) {
        if let position = player?.position {
            if position.distance(between: self.position) < 36 {
                handler(nil)
            }
        }
    }

    /// Update the texture for this door.
    func update() {
        texture = activeTexture
    }

    /// Update the list of inputs and their receivers.
    func updateInputs() {
        for input in inputs {
            input.receivers.append(self)
        }
    }

    /// Toggle the physics body for the door.
    /// - Note: This method should apply for all doors that are not exits.
    func togglePhysicsBody() {
        if active, getBody() != nil { releaseBody() }
        if !active, getBody() == nil {
            instantiateBody(with: getWallPhysicsBody(with: "wall_edge_physics_mask"))
        }
    }
}
