//
//  GameScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/5/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit
import KeyboardShortcuts

// The extension provided here handles keyboard and mouse input to de-clutter the main code.
extension GameScene {
    /// Check the state of the inputs.
    func checkInputStates(_ event: NSEvent) {
        var didTrigger = false
        guard let location = self.playerNode?.position else { return }
        let inputs = self.switches
        for input in inputs where input.position.distance(between: location) < (self.unit?.width ?? 128) / 2
            && input.activationMethod != .activeByPlayerIntervention {
            didTrigger = true
            switch input.kind {
            case .lever:
                input.activate(with: event, player: self.playerNode)
            case .computerT1, .computerT2:
                switch self.playerNode?.costume {
                case .bird where input.kind == .computerT1, .flashDrive where input.kind == .computerT2:
                    input.activate(with: event, player: self.playerNode)
                default:
                    self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false))
                }
            case .alarmClock:
                input.activate(with: event, player: self.playerNode)
            default:
                self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false))
            }
        }
        if !didTrigger { self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false)) }
    }

    /// Listen to keyboard events and run the game logic for key events.
    public override func keyDown(with event: NSEvent) {
        // swiftlint:disable:previous cyclomatic_complexity
        if self.playerDied { return }
        guard let changing = self.playerNode?.isChangingCostumes else { return }
        switch Int(event.keyCode) {
        case KeyboardShortcuts.getShortcut(for: .moveUp)?.carbonKeyCode where !changing:
            self.playerNode?.move(.north, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveDown)?.carbonKeyCode where !changing:
            self.playerNode?.move(.south, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveLeft)?.carbonKeyCode where !changing:
            self.playerNode?.move(.west, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveRight)?.carbonKeyCode where !changing:
            self.playerNode?.move(.east, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .nextCostume)?.carbonKeyCode:
            let costume = self.playerNode?.nextCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .previousCostume)?.carbonKeyCode:
            let costume = self.playerNode?.previousCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .use)?.carbonKeyCode:
            self.checkInputStates(event)
            self.grabItems()
        case KeyboardShortcuts.getShortcut(for: .pause)?.carbonKeyCode:
            self.getPauseScene()
        case KeyboardShortcuts.getShortcut(for: .copy)?.carbonKeyCode:
            self.playerNode?.copyAsObject()
        default:
            break

        }
    }

    /// Listen for keyboard events and halt the player if the movement keys were released.
    public override func keyUp(with event: NSEvent) {
        let movementKeys = KeyboardShortcuts.movementKeys.map { key in key?.carbonKeyCode }
        if movementKeys.contains(Int(event.keyCode)) { self.playerNode?.halt() }
    }
}
