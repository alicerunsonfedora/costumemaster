//
//  Keyboard.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    /// The shortcut that corresponds moving the player up. Defaults to W.
    static let moveUp = Self("moveUp", default: Shortcut(.w))

    /// The shortcut that corresponds to moving the player down. Defaults to S.
    static let moveDown = Self("moveDown", default: Shortcut(.s))

    /// The shortcut that corresponds to moving the player left. Defaults to A.
    static let moveLeft = Self("moveLeft", default: Shortcut(.a))

    /// The shortcut that corresponds to moving the player right. Defaults to D.
    static let moveRight = Self("moveRight", default: Shortcut(.d))

    /// The shortcut that corresponds to switching to the previous costume. Defaults to G.
    static let previousCostume = Self("previousCostume", default: Shortcut(.g))

    /// The shortcut that corresponds to switching to the next costume. Defaults to F.
    static let nextCostume = Self("nextCostume", default: Shortcut(.f))

    /// The shortcut that corresponds to using an item. Defaults to E.
    static let use = Self("use", default: Shortcut(.e))

    /// The shortcut that corresponds to making a copy of the player. Defaults to C.
    static let copy = Self("copy", default: Shortcut(.c))

    /// The shortcut that corresponds to opening the pause menu. Defaults to Escape.
    /// - Note: In its current implementation, this key cannot be changed.
    static let pause = Self("pause", default: Shortcut(.escape))
}

extension KeyboardShortcuts {
    /// Reset all keyboard shortcuts.
    static func resetAll() {
        KeyboardShortcuts.reset(
            [.moveUp, .moveRight, .moveDown, .moveLeft, .nextCostume, .previousCostume, .use, .copy]
        )
    }

    /// The shortcut properties for the movement keys.
    static var movementKeys: [Shortcut?] {
        [
            KeyboardShortcuts.getShortcut(for: .moveDown),
            KeyboardShortcuts.getShortcut(for: .moveUp),
            KeyboardShortcuts.getShortcut(for: .moveLeft),
            KeyboardShortcuts.getShortcut(for: .moveRight),
        ]
    }

    /// The shortcut properties for auxiliary keys such as using and costume changing.
    static var auxiliaryKeys: [Shortcut?] {
        [
            KeyboardShortcuts.getShortcut(for: .nextCostume),
            KeyboardShortcuts.getShortcut(for: .previousCostume),
            KeyboardShortcuts.getShortcut(for: .use),
            KeyboardShortcuts.getShortcut(for: .pause),
            KeyboardShortcuts.getShortcut(for: .copy),
        ]
    }
}
