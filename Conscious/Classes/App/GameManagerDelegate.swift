//
//  GameManagerDelegate.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/2/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import GameKit
import SpriteKit
import Foundation

class GameManagerDelegate {

    /// Whether the game's AI simulator can be run.
    static var canRunSimulator: Bool = true {
        didSet {
            if let main = NSApplication.shared.mainMenu {
                if let game = main.item(withTitle: "Game")?.submenu {
                    game.item(withTitle: "Run AI Simulation...")?.isEnabled = canRunSimulator
                    game.item(withTitle: "Open Simulator Console")?.isEnabled = !canRunSimulator
                    game.item(withTitle: "Record Simulation...")?.isEnabled = canRunSimulator
                }
            }
        }
    }

    /// The game scene associated with the current window.
    static var gameScene: GameScene? {
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            return controller.skView.scene as? GameScene
        }
        return nil
    }

    /// The SKView associated with the current window.
    static var gameView: SKView? {
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            return controller.skView
        }
        return nil
    }

    /// The ViewController associated with the current window.
    static var gameController: ViewController? {
        return NSApplication.shared.mainWindow?.contentViewController as? ViewController
    }

    /// Open the main menu.
    static func callMainMenu() {
        if let view = GameManagerDelegate.gameView {
            if view.scene != nil && view.scene?.name != "MainMenu" {
                confirm("You'll lose any unsaved progress.", withTitle: "Go back to menu?", level: .warning) { resp in
                    if resp.rawValue != 1000 { return }
                    GameManagerDelegate.loadScene(with: "MainMenu")
                }
            }
        }
        if !GameManagerDelegate.canRunSimulator {
            GameManagerDelegate.canRunSimulator = true
        }
    }

    /// Start the game.
    static func startGame() {
        if GameStore.shared.lastSavedScene != "" {
            confirm("You'll lose your level progress.",
                    withTitle: "Are you sure you want to start a new game?",
                    level: .warning
            ) { response in
                if response.rawValue != 1000 { return }
                GameManagerDelegate.loadScene(with: "Intro", fadeDuration: 3.0)
            }
        }
    }

    /// Resume the game from the last saved scene.
    static func resumeGame() {
        GameManagerDelegate.loadScene(with: GameStore.shared.lastSavedScene, fadeDuration: 3.0)
    }

    static func loadRecording(with name: String) {
        if let view = GameManagerDelegate.gameView {
            if let gameScene = AIRecordableGameScene(fileNamed: name + "AIRecordable") {
                print(gameScene.className)
                if view.scene != nil { GameManagerDelegate.gameController?.rootScene = view.scene }
                GKAccessPoint.shared.isActive = name == "MainMenu"
                view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 2.0))
            } else {
                print("Failed to load scene.")
            }
        }
    }

    /// Load a scene with a given name.
    static func loadScene(with name: String, keepHistory: Bool = false) {
        if let view = GameManagerDelegate.gameView {
            if let scene = SKScene(fileNamed: name) {
                if view.scene != nil { GameManagerDelegate.gameController?.rootScene = view.scene }
                GKAccessPoint.shared.isActive = name == "MainMenu"
                view.presentScene(scene)
            }
        }
    }

    /// Load a scene with a given name.
    static func loadScene(with name: String, keepHistory: Bool = false, fadeDuration: TimeInterval) {
        if let view = GameManagerDelegate.gameView {
            if let scene = SKScene(fileNamed: name) {
                if view.scene != nil { GameManagerDelegate.gameController?.rootScene = view.scene }
                GKAccessPoint.shared.isActive = name == "MainMenu"
                view.presentScene(scene, transition: SKTransition.fade(withDuration: fadeDuration))
            }
        }
    }

}
