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

    /// The lable node for the "Quit Game" button.
    var quitButton: SKLabelNode?

    override func sceneDidLoad() {

        // Reset the scale mode to fit accordingly.
        self.scaleMode = .resizeFill

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

        // If the player clicked "Start Game", start the game.
        if self.atPoint(tappedLocation) == self.startButton {
            self.startAction()
        }

        // If the player clicked "Quit Game", close the application.
        if self.atPoint(tappedLocation) == self.quitButton {
            self.quitAction()
        }
    }

    /// Start the game by presenting the first level scene.
    func startAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        if let firstScene = SKScene(fileNamed: "GameScene") {
            self.view?.presentScene(firstScene, transition: SKTransition.fade(with: .black, duration: 2.0))
        }
    }

    /// Close the application.
    func quitAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        NSApplication.shared.terminate(nil)
    }

}
