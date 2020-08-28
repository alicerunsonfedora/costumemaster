//
//  GameSignalReceivable.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//

import Foundation
import SpriteKit

/// A base protocol that defines an object that receives signals from inputs.
protocol GameSignalReceivable {

    // MARK: STORED PROPERTIES

    /// Whether the device is on by default.
    var defaultOn: Bool { get set }

    /// The means of how this receiver will react to input signals.
    var activationMethod: GameSignalMethod { get set }

    /// The inputs that connect to this receiver.
    var inputs: [GameSignalSender] { get set }

    /// The base texture name for this receiver.
    var baseTextureName: String { get set }

    // MARK: COMPUTED PROPERTIES

    /// The texture for this receiver, accounting for the signal state.
    var activeTexture: SKTexture { get }

    /// Whether the receiver is active.
    var active: Bool { get }

    /// The position of the output in context with the level world.
    /// - Note: Use `self.position` to determine the position of the _actual_ note.
    var levelPosition: CGPoint { get set }

    // MARK: METHODS
    /// Initialize a game receiver.
    /// - Parameter inputs: The inputs that the receiver will listen to for signal updates.
    /// - Parameter reverseSignal: Whether to reverse the signal.
    /// - Parameter baseTexture: The name of the base texture to use when creating texture states.
    /// - Parameter location: The location of the output in context with the level.
    init(fromInput inputs: [GameSignalSender], reverseSignal: Bool, baseTexture: String, at location: CGPoint)

}
