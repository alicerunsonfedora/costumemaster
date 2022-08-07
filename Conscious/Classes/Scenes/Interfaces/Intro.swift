//
//  Intro.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/31/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import KeyboardShortcuts
import SpriteKit

/// The SpriteKit scene associated with the intro scene.
class IntroScene: SKScene {
    /// The sprite associated with the level.
    var character: SKSpriteNode?

    /// The label that corresponds to the move up key.
    var moveUpKey: SKLabelNode?

    /// The label that corresponds to the move left key.
    var moveLeftKey: SKLabelNode?

    /// The label that corresponds to the move right key.
    var moveRightKey: SKLabelNode?

    /// The label that corresponds to the move down key.
    var moveDownKey: SKLabelNode?

    /// The label that corresponds to the change costume (previous) key.
    var prevCostumeKey: SKLabelNode?

    /// The label that corresponds to the change costume (next) key.
    var nextCostumeKey: SKLabelNode?

    /// The label that corresponds to the use key.
    var useKey: SKLabelNode?

    /// The label that corresponds to the start button.
    var startButton: SKLabelNode?

    /// Set up the scene and load in the corresponding keyboard shortcuts.
    override func sceneDidLoad() {
        // swiftlint:disable:previous cyclomatic_complexity
        for child in children where child is SKLabelNode {
            if let transformedChild = child as? SKLabelNode {
                transformedChild.fontName = "Cabin Regular"
            }
        }

        for child in children where child is SKSpriteNode {
            if let transformedChild = child as? SKSpriteNode {
                transformedChild.texture?.filteringMode = .nearest
            }
        }

        if let upKey = childNode(withName: "moveUpKey") as? SKLabelNode {
            moveUpKey = upKey
            moveUpKey?.text = KeyboardShortcuts.getShortcut(for: .moveUp)?.description
                ?? "?"
        }

        if let downKey = childNode(withName: "moveDownKey") as? SKLabelNode {
            moveDownKey = downKey
            moveDownKey?.text = KeyboardShortcuts.getShortcut(for: .moveDown)?.description
                ?? "?"
        }

        if let leftKey = childNode(withName: "moveLeftKey") as? SKLabelNode {
            moveLeftKey = leftKey
            moveLeftKey?.text = KeyboardShortcuts.getShortcut(for: .moveLeft)?.description
                ?? "?"
        }

        if let rightKey = childNode(withName: "moveRightKey") as? SKLabelNode {
            moveRightKey = rightKey
            moveRightKey?.text = KeyboardShortcuts.getShortcut(
                for: .moveRight
            )?.description ?? "?"
        }

        if let prevKey = childNode(withName: "prevCostumeKey") as? SKLabelNode {
            prevCostumeKey = prevKey
            prevCostumeKey?.text = KeyboardShortcuts.getShortcut(
                for: .previousCostume
            )?.description ?? "?"
        }

        if let nextKey = childNode(withName: "nextCostumeKey") as? SKLabelNode {
            nextCostumeKey = nextKey
            nextCostumeKey?.text = KeyboardShortcuts.getShortcut(
                for: .nextCostume
            )?.description ?? "?"
        }

        if let useKey = childNode(withName: "useKey") as? SKLabelNode {
            self.useKey = useKey
            self.useKey?.text = KeyboardShortcuts.getShortcut(
                for: .use
            )?.description ?? "?"
        }

        if let start = childNode(withName: "startButton") as? SKLabelNode {
            startButton = start
        }

        if let character = childNode(withName: "character") as? SKSpriteNode {
            self.character = character
        }
    }

    /// Listen for mouse events and start the game when the user presses the start button.
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        if atPoint(location) == startButton {
            startButton?.color = .controlAccentColor
            if let scene = SKScene(fileNamed: "Entry") {
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2.0))
            }
        }
    }
}
