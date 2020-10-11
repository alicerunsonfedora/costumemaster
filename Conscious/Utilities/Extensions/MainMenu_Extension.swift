//
//  MainMenu_Extension.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/10/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit
import Cocoa

#if canImport(SwiftUI)
import SwiftUI
#endif

extension MainMenuScene {
    /// Listen for mouse events and trigger the appropriate menu action.
    override func mouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        // Hook up the button's location tap to the respective action and run it.
        switch self.atPoint(tappedLocation) {
        case self.startButton:
            self.startAction()
        case self.resumeButton where GameStore.shared.lastSavedScene != "":
            self.resumeAction()
        case self.optionsButton:
            self.optionsAction()
        case self.quitButton:
            quitAction()
        case self.watchYourStepButton:
            watchYourStepAction()
        case self.gameCenterButton where self.gameCenterButton?.isHidden != true:
            self.gameCenterAction()
        default:
            break
        }
    }

    /// Listen for mouse events and update the character attributes.
    override func rightMouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        if self.atPoint(tappedLocation) == self.character {
            if !AppDelegate.preferences.canShowUnmodeledOnMenu {
                self.getCharacterAttributes()
            }
        }
    }

    /// Run post-update logic to refresh scene properties.
    override func didFinishUpdate() {
        // Update character preferences based on UserDefaults.
        if AppDelegate.preferences.canShowUnmodeledOnMenu {
            self.character?.texture = SKTexture(
                imageNamed: AppDelegate.preferences.showUnmodeledOnMenu
                    ? "Character_Unmodeled"
                    : "Character"
            )
            self.character?.texture?.filteringMode = .nearest
        }

        if GameStore.shared.lastSavedScene == "" {
            self.resumeButton?.alpha = 0.1
        }

        if let music = self.childNode(withName: "music") as? SKAudioNode {
            music.run(SKAction.changeVolume(to: AppDelegate.preferences.musicVolume, duration: 0.01))
        }

//        if #available(OSX 11.0, *) {
//            self.gameCenterButton?.isHidden = true
//            self.watchYourStepButton?.position.x = 0
//        }

        guard #available(OSX 10.15, *) else {
            self.watchYourStepButton?.alpha = 0.25
            return
        }
    }

    /// Start the game by presenting the first level scene.
    private func startAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        guard let intro = SKScene(fileNamed: "Intro") else { return }
        if #available(OSX 11.0, *) {
            // TODO: Re-enable this when macOS 11 SDK is finalized.
//             GKAccessPoint.shared.isActive = false
        }

        if GameStore.shared.lastSavedScene != "" {
            confirm("You'll lose your level progress.",
                    withTitle: "Are you sure you want to start a new game?",
                    level: .warning
            ) { response in
                if response.rawValue != 1000 {
                    self.startButton?.fontColor = .black
                    return
                }
                self.view?.presentScene(intro, transition: SKTransition.fade(with: .black, duration: 2.0))
            }
        } else {
            self.view?.presentScene(intro, transition: SKTransition.fade(with: .black, duration: 2.0))
        }
    }

    /// Resume the game by loading the last saved scene.
    private func resumeAction() {
        self.resumeButton?.fontColor = NSColor.init(named: "AccentColor")
        if #available(OSX 11.0, *) {
            // TODO: Re-enable this when macOS 11 SDK is finalized.
//             GKAccessPoint.shared.isActive = false
        }
        if let firstScene = SKScene(fileNamed: GameStore.shared.lastSavedScene) {
            self.view?.presentScene(firstScene, transition: SKTransition.fade(with: .black, duration: 2.0))
        }
    }

    /// Show the app's preferences pane.
    private func optionsAction() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.instantiatePreferencesWindow(self)
        }
    }

    /// Close the application.
    private func quitAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        NSApplication.shared.terminate(nil)
    }

    /// Get the appropriate attributes for the character and update the scene.
    ///
    /// This is primarily inspired by Chumbus from Apollo for iOS where a player has to keep interacting with the
    /// character on the main menu.
    private func getCharacterAttributes() {
        self.interactiveLevel += 1
        var title = ""
        var message = ""

        if let menuData = plist(from: "MenuContent") {
            if let data = menuData["Click_\(self.interactiveLevel)"] as? NSDictionary {
                title = data["Title"] as? String ?? ""
                message = data["Message"] as? String ?? ""
                sendAlert(message, withTitle: title, level: .informational) { _ in }
            }
        }

        if self.interactiveLevel == 10000 {
            UserDefaults.standard.setValue(true, forKey: "advShowUnmodeledOnMenuAbility")
            AppDelegate.preferences.showUnmodeledOnMenu = true
            self.character?.texture = SKTexture(imageNamed: "Character_Unmodeled")
            self.character?.texture?.filteringMode = .nearest

            // Unlock the "Face Reveal" achievement in Game Center.
            GKAchievement.earn(with: .faceReveal)
        }
    }

    /// Open the Game Center dashboard.
    /// - Note: This may not works as intended!
    private func gameCenterAction() {
        let gameCenterController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.presentAsSheet(gameCenterController)
        }
    }

    private func watchYourStepAction() {
        guard let sceneController = self.view?.window?.contentViewController else { return }
        if #available(OSX 10.15, *) {
            let viewController = NSViewController()
            let dlcDialog = WatchYourStepView {
                sceneController.dismiss(viewController)
                if let first = SKScene(fileNamed: "Consequences") {
                    self.view?.presentScene(first, transition: SKTransition.fade(withDuration: 3.0))
                }
            } onDismiss: {
                sceneController.dismiss(viewController)
            }
            viewController.view = NSHostingView(rootView: dlcDialog)
            sceneController.presentAsSheet(viewController)
        }
    }
}