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
import SpriteKit
import Foundation

class GameManagerDelegate {

    static var gameScene: GameScene? {
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            return controller.skView.scene as? GameScene
        }
        return nil
    }

    static var gameView: SKView? {
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            return controller.skView
        }
        return nil
    }

    static var gameController: ViewController? {
        return NSApplication.shared.mainWindow?.contentViewController as? ViewController
    }

    static func callMainMenu() {
        if let view = GameManagerDelegate.gameView {
            if view.scene != nil && view.scene?.name != "MainMenu" {
                confirm("You'll lose any unsaved progress.", withTitle: "Go back to menu?", level: .warning) { resp in
                    if resp.rawValue != 1000 { return }
                    GameManagerDelegate.loadScene(with: "MainMenu")
                }
            }
        }
    }

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

    static func resumeGame() {
        GameManagerDelegate.loadScene(with: GameStore.shared.lastSavedScene, fadeDuration: 3.0)
    }

    static func loadScene(with name: String, keepHistory: Bool = false) {
        if let view = GameManagerDelegate.gameView {
            if let scene = SKScene(fileNamed: name) {
                if view.scene != nil { GameManagerDelegate.gameController?.rootScene = view.scene }
                view.presentScene(scene)
            }
        }
    }

    static func loadScene(with name: String, keepHistory: Bool = false, fadeDuration: TimeInterval) {
        if let view = GameManagerDelegate.gameView {
            if let scene = SKScene(fileNamed: name) {
                if view.scene != nil { GameManagerDelegate.gameController?.rootScene = view.scene }
                view.presentScene(scene, transition: SKTransition.fade(withDuration: fadeDuration))
            }
        }
    }

}
