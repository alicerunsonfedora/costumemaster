//
//  PauseScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import KeyboardShortcuts

/// The SpriteKit scene class for the pause menu.
class PauseScene: SKScene {

    /// The label node that corresponds to the main menu button.
    var mainMenuButton: SKLabelNode?

    /// The label node that corresponds to the options button.
    var optionsButton: SKLabelNode?

    /// The label node that corresponds to the resume button.
    var resumeButton: SKLabelNode?

    /// The lavel node that corresponds to the restart button.
    var restartButton: SKLabelNode?

    /// Set up the scene and hook up the buttons to make the pause menu functional.
    override func sceneDidLoad() {
        guard let mainMenu = self.childNode(withName: "mainMenuButton") as? SKLabelNode else { return }
        self.mainMenuButton = mainMenu
        self.mainMenuButton?.fontName = "Cabin Regular"
        self.mainMenuButton?.text = NSLocalizedString("costumemaster.ui.pause_main", comment: "Back to main menu")

        guard let options = self.childNode(withName: "optionsButton") as? SKLabelNode else { return }
        self.optionsButton = options
        self.optionsButton?.fontName = "Cabin Regular"
        self.optionsButton?.text = NSLocalizedString("costumemaster.ui.pause_options", comment: "Options")

        guard let resume = self.childNode(withName: "resumeButton") as? SKLabelNode else { return }
        self.resumeButton = resume
        self.resumeButton?.fontName = "Cabin Regular"
        self.resumeButton?.text = NSLocalizedString("costumemaster.ui.pause_resume", comment: "Resume")

        guard let restart = self.childNode(withName: "restartButton") as? SKLabelNode else { return }
        self.restartButton = restart
        self.restartButton?.fontName = "Cabin Regular"
        self.restartButton?.text = NSLocalizedString("costumemaster.ui.pause_restart", comment: "Restart")
    }

    /// Listen for mouse events and trigger the corresponding menu action.
    override func mouseDown(with event: NSEvent) {
        let tapped = event.location(in: self)

        switch self.atPoint(tapped) {
        case resumeButton:
            self.resumeAction()
        case restartButton:
            self.restartAction()
        case optionsButton:
            self.optionsAction()
        case mainMenuButton:
            self.mainMenuAction()
        default:
            break
        }
    }

    /// Listen for keyboard events and return when the user presses the pause key.
    override func keyDown(with event: NSEvent) {
        if Int(event.keyCode) == KeyboardShortcuts.getShortcut(for: .pause)?.carbonKeyCode {
            self.resumeAction()
        }
    }

    /// Execute the action that corresponds to the main menu button.
    private func mainMenuAction() {
        confirm(
            NSLocalizedString("costumemaster.confirm.back_to_main", comment: "Back to main menu"),
            withTitle: NSLocalizedString("costumemaster.confirm.back_to_main_title", comment: "Back to main title"),
            level: .warning
        ) { resp in
            if resp.rawValue != 1000 { return }
            if let scene = SKScene(fileNamed: "MainMenu") as? MainMenuScene {
                self.view?.presentScene(scene)
            }
        }
    }

    /// Execute the action that corresponds to the options button.
    private func optionsAction() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.instantiatePreferencesWindow(self)
        }
    }

    /// Execute the action that corresponds to the resume button.
    private func resumeAction() {
        if let controller = self.view?.window?.contentViewController as? ViewController {
            if controller.rootScene == nil { return }
            self.view?.presentScene(controller.rootScene!, transition: SKTransition.fade(withDuration: 0.10))
            controller.rootScene = nil
        }
    }

    /// Excecute the action that corresponds to the restart button.
    private func restartAction() {
        confirm(
            NSLocalizedString("costumemaster.confirm.restart", comment: "Restart level"),
            withTitle: NSLocalizedString("costumemaster.confirm.restart_title", comment: "Restart level title"),
            level: .warning
        ) { resp in
            if resp.rawValue != 1000 { return }
            if let controller = self.view?.window?.contentViewController as? ViewController {
                if let scene = SKScene(fileNamed: controller.rootScene?.name ?? "") {
                    self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
                }
            }
        }
    }

}
