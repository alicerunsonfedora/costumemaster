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
import GameKit
import SpriteKit

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
    /// - Important: This field has been deprecated and will be removed in a future release. Please use ``GKAccessPoint`` instead.
    @available(*, deprecated, message: "Game Center button has been fully replaced with GKAccessPoint.")
    var gameCenterButton: SKSpriteNode?

    /// The sprite node for the Watch Your Step DLC.
    var watchYourStepButton: SKSpriteNode?

    /// The sprite node for the 'Try The Costumemaster: Reloaded' button.
    var reloadedButton: SKSpriteNode?

    /// The level of interactivity from this scene.
    var interactiveLevel: Int = 0

    /// Whether to set character attributes for this scene.
    var setCharacterAttributes: Bool = false

    /// Instantiate the Game Center access point.
    ///
    /// In macOS 11.0, this will use the native access point and put it in the bottom left. For older versions, a sprite
    /// node will be used to present a Game Center view.
    ///
    /// - Important: This method has been deprecated and will be replaced by ``instantiateAccessPoint``.
    /// - SeeAlso: ``instantiateAccessPoint``
    @available(*, deprecated, renamed: "instantiateAccessPoint")
    func setUpGameCenterProperties() {
        instantiateAccessPoint()
    }

    /// Set up the Game Center button for the main menu.
    override func didMove(to _: SKView) {
        instantiateAccessPoint()
    }

    /// Set up the scene and play the main menu music.
    override func sceneDidLoad() {
        // Reset the scale mode to fit accordingly.
        scaleMode = .aspectFill

        // Instantiate the appropriate label nodes and add their fonts, respectively.
        if let label = childNode(withName: "smallLabel") as? SKLabelNode {
            labelSmall = label
            labelSmall?.fontName = "Cabin Regular"
        }

        if let title = childNode(withName: "titleLabel") as? SKLabelNode {
            labelTitle = title
            labelTitle?.fontName = "Dancing Script Regular Regular"
        }

        if let start = childNode(withName: "startGame") as? SKLabelNode {
            startButton = start
            startButton?.fontName = "Cabin Regular"
            startButton?.text = NSLocalizedString("costumemaster.ui.main_new_game", comment: "New Game")
        }

        if let options = childNode(withName: "showOptions") as? SKLabelNode {
            optionsButton = options
            optionsButton?.fontName = "Cabin Regular"
            optionsButton?.text = NSLocalizedString("costumemaster.ui.main_options", comment: "Options")
        }

        if let quit = childNode(withName: "quitGame") as? SKLabelNode {
            quitButton = quit
            quitButton?.fontName = "Cabin Regular"
            quitButton?.text = NSLocalizedString("costumemaster.ui.main_quit", comment: "Quit Game")
        }

        if let resume = childNode(withName: "resumeGame") as? SKLabelNode {
            resumeButton = resume
            resumeButton?.fontName = "Cabin Regular"
            resumeButton?.text = NSLocalizedString("costumemaster.ui.main_load_game", comment: "Resume Game")

            if GameStore.shared.lastSavedScene == "" {
                resumeButton?.alpha = 0.1
            }
        }

        if let dlcButton = childNode(withName: "dlcButton") as? SKSpriteNode {
            watchYourStepButton = dlcButton
            watchYourStepButton?.texture?.filteringMode = .nearest
        }

        if let reloadedButton = childNode(withName: "reloadedButton") as? SKSpriteNode {
            self.reloadedButton = reloadedButton
        }

        // Get the character sprite and change the interpolation method to nearest neighbor.
        if let char = childNode(withName: "character") as? SKSpriteNode {
            character = char

            if UserDefaults.canShowUnmodeled, UserDefaults.showUnmodeled {
                character?.texture = SKTexture(imageNamed: "Character_Unmodeled")
            }

            character?.texture?.filteringMode = .nearest
        }

        let music = SKAudioNode(fileNamed: "minute")
        music.name = "music"
        music.autoplayLooped = true
        music.isPositional = false
        music.run(SKAction.sequence([
            SKAction.changeVolume(to: UserDefaults.musicVolume, duration: 0.01),
            SKAction.play(),
        ]))
        addChild(music)
    }

    /// Dismiss the Game Center view controller when done.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let sceneViewController = view?.window?.contentViewController {
            sceneViewController.dismiss(gameCenterViewController)
        }
    }

    /// Insantiates the Game Center access point introduced in macOS 11.
    ///
    /// This is used to show the player their Game Center achievements and leaderboard scores.
    private func instantiateAccessPoint() {
        GKAccessPoint.shared.location = .bottomLeading
        GKAccessPoint.shared.showHighlights = true
        GKAccessPoint.shared.isActive = true
        GKAccessPoint.shared.parentWindow = NSApplication.shared.mainWindow
    }
}
