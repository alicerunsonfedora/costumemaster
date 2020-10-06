//
//  MainMenu.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// The scene class for the main menu.
class MainMenuScene: SKScene, GKGameCenterControllerDelegate {

    /// The label node for the word "The".
    var labelSmall: SKLabelNode?

    /// The label node for the title.
    var labelTitle: SKLabelNode?

    /// The sprite node with the character.
    var character: SKSpriteNode?

    /// The label node for the "Start Game" button.
    var startButton: SKLabelNode?

    /// The label node for the "Resume Game" button.
    var resumeButton: SKLabelNode?

    /// The label node for the "Options" button.
    var optionsButton: SKLabelNode?

    /// The label node for the "Quit Game" button.
    var quitButton: SKLabelNode?

    /// The Game Center sprite node for the Game Center dashboard.
    /// - Note: This should only be used in older versions of macOS. In macOS 11.0, the GKAccessPoint is used instead.
    var gameCenterButton: SKSpriteNode?

    /// The level of interactivity from this scene.
    private var interactiveLevel: Int = 0

    private var setCharacterAttributes: Bool = false

    /// Instantiate the Game Center access point.
    ///
    /// In macOS 11.0, this will use the native access point and put it in the bottom left. For older versions, a sprite
    /// node will be used to present a game center view.
    func setUpGameCenterProperties() {
        // TODO: Re-enable this when macOS 11 SDK is finalized.
//        if #available(OSX 11.0, *) {
//            self.gameCenterButton?.isHidden = true
//            GKAccessPoint.shared.location = .bottomLeading
//            GKAccessPoint.shared.showHighlights = true
//            GKAccessPoint.shared.isActive = true
//            GKAccessPoint.shared.parentWindow = self.view?.window
//        }
    }

    /// Set up the Game Center button for the main menu.
    override func didMove(to view: SKView) {
        if let gCenter = self.childNode(withName: "gameCenter") as? SKSpriteNode {
            self.gameCenterButton = gCenter
        }

        // Display the Game Center access point.
        self.setUpGameCenterProperties()
    }

    /// Set up the scene and play the main menu music.
    override func sceneDidLoad() {

        // Reset the scale mode to fit accordingly.
        self.scaleMode = .aspectFill

        // Instantiate the appropriate label nodes and add their fonts, respectively.
        if let label = self.childNode(withName: "smallLabel") as? SKLabelNode {
            self.labelSmall = label
            self.labelSmall?.fontName = "Cabin Regular"
        }

        if let title = self.childNode(withName: "titleLabel") as? SKLabelNode {
            self.labelTitle = title
            self.labelTitle?.fontName = "Dancing Script Regular Regular"
        }

        if let start = self.childNode(withName: "startGame") as? SKLabelNode {
            self.startButton = start
            self.startButton?.fontName = "Cabin Regular"
        }

        if let options = self.childNode(withName: "showOptions") as? SKLabelNode {
            self.optionsButton = options
            self.optionsButton?.fontName = "Cabin Regular"
        }

        if let quit = self.childNode(withName: "quitGame") as? SKLabelNode {
            self.quitButton = quit
            self.quitButton?.fontName = "Cabin Regular"
        }

        if let resume = self.childNode(withName: "resumeGame") as? SKLabelNode {
            self.resumeButton = resume
            self.resumeButton?.fontName = "Cabin Regular"

            if GameStore.shared.lastSavedScene == "" {
                self.resumeButton?.alpha = 0.1
            }
        }

        // Get the character sprite and change the interpolation method to nearest neighbor.
        if let char = self.childNode(withName: "character") as? SKSpriteNode {
            self.character = char

            if AppDelegate.preferences.canShowUnmodeledOnMenu && AppDelegate.preferences.showUnmodeledOnMenu {
                self.character?.texture = SKTexture(imageNamed: "Character_Unmodeled")
            }

            self.character?.texture?.filteringMode = .nearest
        }

        let music = SKAudioNode(fileNamed: "Smoldering")
        music.name = "music"
        music.autoplayLooped = true
        music.isPositional = false
        music.run(SKAction.sequence([
            SKAction.changeVolume(to: AppDelegate.preferences.musicVolume, duration: 0.01),
            SKAction.play()
        ]))
        self.addChild(music)
    }

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
//        }
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

        print(self.interactiveLevel)

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

    // MARK: GAME CENTER

    /// Open the Game Center dashboard.
    /// - Note: This may not works as intended!
    private func gameCenterAction() {
        let gameCenterController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.presentAsSheet(gameCenterController)
        }
    }

    /// Dismiss the Game Center view controller when done.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.dismiss(gameCenterViewController)
        }
    }

}
