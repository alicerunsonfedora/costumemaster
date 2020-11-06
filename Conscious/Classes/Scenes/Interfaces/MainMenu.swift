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

    /// The sprite node for the Watch Your Step DLC.
    var watchYourStepButton: SKSpriteNode?

    /// The level of interactivity from this scene.
    var interactiveLevel: Int = 0

    /// Whether to set character attributes for this scene.
    var setCharacterAttributes: Bool = false

    /// Instantiate the Game Center access point.
    ///
    /// In macOS 11.0, this will use the native access point and put it in the bottom left. For older versions, a sprite
    /// node will be used to present a game center view.
    func setUpGameCenterProperties() {
        if #available(OSX 11.0, *) {
            self.gameCenterButton?.isHidden = true

            GKAccessPoint.shared.location = .bottomLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            GKAccessPoint.shared.parentWindow = self.view?.window

            self.watchYourStepButton?.position.x = 0
        }
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

        if let dlcButton = self.childNode(withName: "dlcButton") as? SKSpriteNode {
            self.watchYourStepButton = dlcButton
            self.watchYourStepButton?.texture?.filteringMode = .nearest
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

    /// Dismiss the Game Center view controller when done.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.dismiss(gameCenterViewController)
        }
    }

}
