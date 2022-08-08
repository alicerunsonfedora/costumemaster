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
import GameKit
import KeyboardShortcuts
import SpriteKit

// The extension provided here handles keyboard and mouse input to de-clutter the main code.
extension GameScene {
    // MARK: STATE MANAGEMENT

    /// Check the state of the inputs.
    func checkInputStates(_ event: NSEvent) {
        var didTrigger = false
        guard let location = playerNode?.position else { return }
        let inputs = switches
        for input in inputs where input.position.distance(between: location) < (unit?.width ?? 128) / 2
            && !input.activationMethod.contains(.activeByPlayerIntervention)
        {
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
        if !didTrigger { run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false)) }
    }

    /// Check the wall states and update their physics bodies.
    /// - Parameter costume: The costume to run the checks against.
    func checkWallStates(with costume: PlayerCostumeType?) {
        for node in structure.children where node.name != nil && node.name!.starts(with: "wall_") {
            guard let wall = node as? GameStructureObject else { return }
            guard let name = wall.name else { return }
            let body = name.contains("_edge") ? "wall_edge_physics_mask" : "wall_top"
            if wall.locked { continue }
            if costume == .bird {
                wall.releaseBody()
            } else {
                wall.instantiateBody(with: getWallPhysicsBody(with: body))
            }
        }
    }

    /// Check the state of the doors in the level.
    func checkDoorStates() {
        for node in receivers where node is DoorReceiver && node != exitNode {
            guard let door = node as? DoorReceiver else { return }; door.togglePhysicsBody()
        }
    }

    /// Drop or pickup items near the player.
    func grabItems() {
        for item in interactables {
            if item.carrying { item.resign(from: playerNode) } else { item.attach(to: playerNode) }
        }
    }

    /// Get the pause menu screen and load it.
    func getPauseScene() {
        guard let controller = view?.window?.contentViewController as? ViewController else { return }
        controller.rootScene = self; callScene(name: "PauseMenu")
    }

    /// Make state updates that inform the player that they have "died".
    func kill() {
        playerDied = true
        let deathOverlay = SKSpriteNode(color: NSColor(named: "Skybox") ?? .red, size: size)
        deathOverlay.zPosition = 999_999_999_999; deathOverlay.position = playerNode?.position ?? .zero
        deathOverlay.alpha = 0
        addChild(deathOverlay)
        playerNode?.halt()
        runSequence {
            SKAction.run { self.playerNode?.run(SKAction.fadeAlpha(to: 0.0, duration: 0.5)) }
            SKAction.run { deathOverlay.run(SKAction.fadeAlpha(to: 0.5, duration: 2.0)) }
            SKAction.playSoundFileNamed("death", waitForCompletion: true)
            SKAction.run {
                GKNotificationBanner.show(
                    withTitle: "You fell down the abyss!",
                    message: "The level will restart shortly."
                ) {}
            }
            SKAction.wait(forDuration: 3.0)
            SKAction.run { self.callScene(name: self.name) }
        }
    }

    // MARK: INPUT TRIGGER EVENTS

    /// Listen to keyboard events and run the game logic for key events.
    override public func keyDown(with event: NSEvent) {
        // swiftlint:disable:previous cyclomatic_complexity
        if playerDied { return }
        switch Int(event.keyCode) {
        case KeyboardShortcuts.getShortcut(for: .moveUp)?.carbonKeyCode:
            playerNode?.move(.north, unit: unit!)
        case KeyboardShortcuts.getShortcut(for: .moveDown)?.carbonKeyCode:
            playerNode?.move(.south, unit: unit!)
        case KeyboardShortcuts.getShortcut(for: .moveLeft)?.carbonKeyCode:
            playerNode?.move(.west, unit: unit!)
        case KeyboardShortcuts.getShortcut(for: .moveRight)?.carbonKeyCode:
            playerNode?.move(.east, unit: unit!)
        case KeyboardShortcuts.getShortcut(for: .nextCostume)?.carbonKeyCode:
            let costume = playerNode?.nextCostume()
            checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .previousCostume)?.carbonKeyCode:
            let costume = playerNode?.previousCostume()
            checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .use)?.carbonKeyCode:
            checkInputStates(event)
            grabItems()
        case KeyboardShortcuts.getShortcut(for: .pause)?.carbonKeyCode:
            getPauseScene()
        case KeyboardShortcuts.getShortcut(for: .copy)?.carbonKeyCode:
            playerNode?.copyAsObject()
        default:
            break
        }
    }

    /// Listen for keyboard events and halt the player if the movement keys were released.
    override public func keyUp(with event: NSEvent) {
        let movementKeys = KeyboardShortcuts.movementKeys.map { key in key?.carbonKeyCode }
        if movementKeys.contains(Int(event.keyCode)) { playerNode?.halt() }
    }
}
