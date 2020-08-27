//
//  MainMenu.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//

import Foundation
import SpriteKit

/// The scene class for the main menu.
class MainMenuScene: SKScene {

    /// The label node for the word "The".
    var labelSmall: SKLabelNode?

    /// The label node for the title.
    var labelTitle: SKLabelNode?

    /// The sprite node with the character.
    var character: SKSpriteNode?

    /// The label node for the "Start Game" button.
    var startButton: SKLabelNode?

    /// The label node for the "Options" button.
    var optionsButton: SKLabelNode?

    /// The lable node for the "Quit Game" button.
    var quitButton: SKLabelNode?

    private var setCharacterAttributes: Bool = false

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

        // Get the character sprite and change the interpolation method to nearest neighbor.
        if let char = self.childNode(withName: "character") as? SKSpriteNode {
            self.character = char
            self.character?.texture?.filteringMode = .nearest
        }

    }

    override func mouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        // Hook up the button's location tap to the respective action and run it.
        switch self.atPoint(tappedLocation) {
        case self.startButton:
            self.startAction()
        case self.optionsButton:
            self.optionsAction()
        case self.quitButton:
            quitAction()
        default:
            break
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        if self.atPoint(tappedLocation) == self.character {
            self.getCharacterAttributes()
        }
    }

    /// Start the game by presenting the first level scene.
    private func startAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        if let firstScene = SKScene(fileNamed: "GameScene") {
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

    /// Reset the character attributes.
    private func getCharacterAttributes() {
        self.character?.texture = SKTexture(
            imageNamed: self.setCharacterAttributes ? "Character_Unmodeled" : "Character"
        )
        self.character?.texture?.filteringMode = .nearest
        self.setCharacterAttributes.toggle()
    }

}
