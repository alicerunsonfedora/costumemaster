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
    static let moveUp = Self("moveUp", default: Shortcut(.w))
    static let moveDown = Self("moveDown", default: Shortcut(.s))
    static let moveLeft = Self("moveLeft", default: Shortcut(.a))
    static let moveRight = Self("moveRight", default: Shortcut(.d))
    static let previousCostume = Self("previousCostume", default: Shortcut(.g))
    static let nextCostume = Self("nextCostume", default: Shortcut(.f))
    static let use = Self("use", default: Shortcut(.e))
    static let pause = Self("pause", default: Shortcut(.escape))
}

extension KeyboardShortcuts {
    /// Reset all keyboard shortcuts.
    static func resetAll() {
        KeyboardShortcuts.reset([.moveUp, .moveRight, .moveDown, .moveLeft, .nextCostume, .previousCostume, .use])
    }

    /// The shortcut properties for the movement keys.
    static var movementKeys: [Shortcut?] {
        return [
            KeyboardShortcuts.getShortcut(for: .moveDown),
            KeyboardShortcuts.getShortcut(for: .moveUp),
            KeyboardShortcuts.getShortcut(for: .moveLeft),
            KeyboardShortcuts.getShortcut(for: .moveRight)
        ]
    }

    /// The shortcut properties for auxiliary keys such as using and costume changing.
    static var auxiliaryKeys: [Shortcut?] {
        return [
            KeyboardShortcuts.getShortcut(for: .nextCostume),
            KeyboardShortcuts.getShortcut(for: .previousCostume),
            KeyboardShortcuts.getShortcut(for: .use),
            KeyboardShortcuts.getShortcut(for: .pause)
        ]
    }
}
