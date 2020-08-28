//
//  LevelExitDoor.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//

import Foundation
import SpriteKit

/// An exit door.
public class LevelExitDoor: SKSpriteNode, GameSignalReceivable {

    // MARK: STORED PROPERTIES
    var defaultOn: Bool

    var activationMethod: GameSignalMethod

    var inputs: [GameSignalSender]

    var baseTextureName: String

    var playerListener: Player?

    var levelPosition: CGPoint

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
        self.defaultOn = inputs.isEmpty
        self.inputs = inputs
        self.baseTextureName = baseTexture
        self.activationMethod = .allInputs
        self.levelPosition = location
        if reverseSignal { self.defaultOn.toggle() }

        super.init(
            texture: SKTexture(imageNamed: baseTexture + "_off"),
            color: .clear,
            size: SKTexture(imageNamed: baseTexture + "_off").size()
        )

        self.inputs.forEach { input in input.receiver = self }
        self.texture = self.activeTexture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: METHODS

    private func instantiatePhysicsBody() -> SKPhysicsBody {
        return getWallPhysicsBody(with: self.activeTexture)
    }

    func receive(with player: Player?, event: NSEvent?, handler: ((Any?) -> Void)) {
        if self.active {
            self.physicsBody = nil
        } else {
            self.physicsBody = instantiatePhysicsBody()
            return
        }
        if let position = player?.position {
            if position.distance(between: self.position) < (self.texture?.size().width ?? 1) / 4 {
                handler(nil)
            }
        }
    }

}
