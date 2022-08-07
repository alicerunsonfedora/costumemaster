//
//  GameSignalReceivable.swift
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

/// A base protocol that defines an object that receives signals from inputs.
protocol GameSignalReceivable: GameTileSpriteNode {
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

    // MARK: METHODS

    /// Initialize a game receiver.
    /// - Parameter inputs: The inputs that the receiver will listen to for signal updates.
    /// - Parameter reverseSignal: Whether to reverse the signal.
    /// - Parameter baseTexture: The name of the base texture to use when creating texture states.
    /// - Parameter location: The location of the output in context with the level.
    init(fromInput inputs: [GameSignalSender], reverseSignal: Bool, baseTexture: String, at location: CGPoint)

    /// Update the properties of the receiver's sprite.
    /// - Important: Do not store logic-related function such as activity status inside this method. This method
    /// is used specifically to make visual changes on every frame.
    func update()

    /// Update the status of this receiver based on new inputs.
    func updateInputs()
}
