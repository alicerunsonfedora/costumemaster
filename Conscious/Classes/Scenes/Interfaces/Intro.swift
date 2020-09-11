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

    // swiftlint:disable:next cyclomatic_complexity
    override func sceneDidLoad() {
        for child in self.children where child is SKLabelNode {
            if let transformedChild = child as? SKLabelNode {
                transformedChild.fontName = "Cabin Regular"
            }
        }

        for child in self.children where child is SKSpriteNode {
            if let transformedChild = child as? SKSpriteNode {
                transformedChild.texture?.filteringMode = .nearest
            }
        }

        if let upKey = self.childNode(withName: "moveUpKey") as? SKLabelNode {
            self.moveUpKey = upKey
            self.moveUpKey?.text = KeyboardShortcuts.getShortcut(for: .moveUp)?.description
                ?? "?"
        }

        if let downKey = self.childNode(withName: "moveDownKey") as? SKLabelNode {
            self.moveDownKey = downKey
            self.moveDownKey?.text = KeyboardShortcuts.getShortcut(for: .moveDown)?.description
                ?? "?"
        }

        if let leftKey = self.childNode(withName: "moveLeftKey") as? SKLabelNode {
            self.moveLeftKey = leftKey
            self.moveLeftKey?.text = KeyboardShortcuts.getShortcut(for: .moveLeft)?.description
                ?? "?"
        }

        if let rightKey = self.childNode(withName: "moveRightKey") as? SKLabelNode {
            self.moveRightKey = rightKey
            self.moveRightKey?.text = KeyboardShortcuts.getShortcut(
                for: .moveRight
            )?.description ?? "?"
        }

        if let prevKey = self.childNode(withName: "prevCostumeKey") as? SKLabelNode {
            self.prevCostumeKey = prevKey
            self.prevCostumeKey?.text = KeyboardShortcuts.getShortcut(
                for: .previousCostume
            )?.description ?? "?"
        }

        if let nextKey = self.childNode(withName: "nextCostumeKey") as? SKLabelNode {
            self.nextCostumeKey = nextKey
            self.nextCostumeKey?.text = KeyboardShortcuts.getShortcut(
                for: .nextCostume
            )?.description ?? "?"
        }

        if let useKey = self.childNode(withName: "useKey") as? SKLabelNode {
            self.useKey = useKey
            self.useKey?.text = KeyboardShortcuts.getShortcut(
                for: .use
            )?.description ?? "?"
        }

        if let start = self.childNode(withName: "startButton") as? SKLabelNode {
            self.startButton = start
        }

        if let character = self.childNode(withName: "character") as? SKSpriteNode {
            self.character = character
        }
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        if self.atPoint(location) == self.startButton {
            self.startButton?.color = .controlAccentColor
            if let scene = SKScene(fileNamed: "Entry") {
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2.0))
            }
        }
    }

}
