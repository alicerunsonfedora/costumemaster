//
//  GameSignalSender.swift
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

/// A base class that determines an input.
public class GameSignalSender: GameStructureObject {

    // MARK: STORED PROPERTIES

    /// Whether the input is currently active. Defaults to false.
    public var active: Bool = false

    /// The method that this input will activate. Default is by player intervention.
    public var activationMethod: GameSignalInputMethod = .activeByPlayerIntervention

    /// The kind of sender. Defaults to a trigger.
    public var kind: GameSignalKind = .trigger

    /// The input's associated receiver.
    var receivers: [GameSignalReceivable]

    /// The name of the base texture for this input.
    var baseTexture: String

    /// The number of seconds it takes for the input to toggle.
    var cooldown: Double

    /// The position of this input in context with the level.
    /// - Note: Use `self.position` for position of the _actual_ node.
    let levelPosition: CGPoint

    // MARK: COMPUTED PROPERTIES
    /// The texture for this input, accounting for active states.
    var activeTexture: SKTexture {
        return SKTexture(imageNamed: self.baseTexture + (self.active ? "_on" : "_off"))
    }

    /// The description for this class.
    public override var description: String {
        return "\(self.className)(active: \(self.active), outputs: \(self.receivers), position: \(self.levelPosition))"
    }

    // MARK: CONSTRUCTOR
    /// Initialize the input.
    /// - Parameter textureName: The name of the texture for this input.
    /// - Parameter inputMethod: The means of which this input will be activated by.
    public init(textureName: String, by inputMethod: GameSignalInputMethod, at position: CGPoint) {
        self.baseTexture = textureName
        self.activationMethod = inputMethod
        self.cooldown = 0
        self.levelPosition = position
        self.receivers = []
        super.init(
            with: SKTexture(imageNamed: textureName + "_off"),
            size: SKTexture(imageNamed: textureName + "_off").size()
        )
        self.texture = self.activeTexture
    }

    // MARK: CONSTRUCTOR
    /// Initialize the input.
    /// - Parameter textureName: The name of the texture for this input.
    /// - Parameter inputMethod: The means of which this input will be activated by.
    /// - Parameter timer: The number of seconds it takes for this input to toggle states.
    public init(
        textureName: String,
        by inputMethod: GameSignalInputMethod,
        at position: CGPoint,
        with timer: Double
    ) {
        self.baseTexture = textureName
        self.cooldown = timer
        self.activationMethod = inputMethod
        self.levelPosition = position
        self.receivers = []
        super.init(
            with: SKTexture(imageNamed: textureName + "_off"),
            size: SKTexture(imageNamed: textureName + "_off").size()
        )
        self.texture = self.activeTexture
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: METHODS
    /// Toggle the active state for this input.
    private func toggle() {
        self.active.toggle()
        self.texture = self.activeTexture
    }

    /// Set the state of this input as active.
    private func setActiveState() {
        self.active = true
        self.texture = self.activeTexture
        for receiver in self.receivers {
            receiver.update()
        }
    }

    /// Set the state of this input as inactive.
    private func setInactiveState() {
        self.active = false
        self.texture = self.activeTexture
    }

    /// Activate the input given an event and player.
    /// - Parameter event: The event handler to listen to and track.
    /// - Parameter player: The player to watch and track.
    public func activate(with event: NSEvent?, player: Player?, objects: [SKSpriteNode?] = []) {
        switch activationMethod {
        case .activeByPlayerIntervention:
            if shouldActivateOnIntervention(with: player, objects: objects) {
                self.setActiveState()
                self.onActivate(with: event, player: player)
            } else {
                self.setInactiveState()
                self.onDeactivate(with: event, player: player)
            }
        case .activeOnTimer:
            self.run(
                SKAction.sequence(
                    [
                        SKAction.run { self.setActiveState() },
                        SKAction.run { self.onActivate(with: event, player: player) },
                        SKAction.wait(forDuration: self.cooldown),
                        SKAction.run { self.setInactiveState() },
                        SKAction.run { self.onDeactivate(with: event, player: player) }
                    ]
                )
            )
        case .activeOncePermanently:
            self.setActiveState()
        }
    }

    /// Whether the input should turn on/off based on player or object intervention.
    /// - Parameter player: The player to listen to for intervention.
    /// - Parameter objects: The objects to listen to for intervention.
    /// - Returns: Whether the input should activate given the intervention criteria.
    /// - Important: This method should be implemented on inputs that listen to player intervention.
    /// This will default to false otherwise.
    public func shouldActivateOnIntervention(with player: Player?, objects: [SKSpriteNode?]) -> Bool {
        return false
    }

    /// Run any post-activation methods.
    /// - Parameter event: The event handler that triggered the activation.
    /// - Parameter player: The player that triggered the activation.
    public func onActivate(with event: NSEvent?, player: Player?) {
        print("onActivate has not been implemented.")
    }

    /// Run any post-deactivation methods.
    /// - Parameter event: The event handler that triggered the activation.
    /// - Parameter player: The player that triggered the activation.
    public func onDeactivate(with event: NSEvent?, player: Player?) {
        print("onDeactivate has not been implemented.")
    }
}
