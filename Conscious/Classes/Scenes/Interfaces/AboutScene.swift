//
//  AboutScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/10/20.
//

import Foundation
import KeyboardShortcuts
import SpriteKit

/// The SpriteKit scene class for the about screen.
class AboutScene: SKScene {
    /// The label node that corresponds to the back button.
    var backButton: SKLabelNode?

    /// The label node that corresponds to the title of the game.
    var title: SKLabelNode?

    /// The label node that corresponds to the version string.
    var versionString: SKLabelNode?

    /// Go back to the previous scene.
    private func goBack() {
        if let controller = view?.window?.contentViewController as? ViewController {
            guard let home = SKScene(fileNamed: "MainMenu") else { return }
            view?.presentScene(controller.rootScene != nil ? controller.rootScene : home)
        }
    }

    /// Set up the about scene and fill in the appropriate data.
    override func sceneDidLoad() {
        // Reset the scale mode to fit accordingly.
        scaleMode = .aspectFill

        for child in children where child is SKLabelNode {
            if let text = child as? SKLabelNode {
                text.fontName = "Cabin Regular"
            }
        }

        for child in children where child is SKSpriteNode {
            if let sprite = child as? SKSpriteNode {
                sprite.texture?.filteringMode = .nearest
            }
        }

        if let title = childNode(withName: "title") as? SKLabelNode {
            self.title = title
            self.title?.fontName = "Dancing Script Regular"
        }

        if let versionString = childNode(withName: "version") as? SKLabelNode {
            self.versionString = versionString
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                ?? "0.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            self.versionString?.text = "Version \(version) (Build \(build))"
        }

        if let copyString = childNode(withName: "copyrightText") as? SKLabelNode {
            copyString.text = NSLocalizedString("costumemaster.ui.about_copyright", comment: "Copyright text")
        }

        if let back = childNode(withName: "back") as? SKLabelNode {
            backButton = back
            backButton?.text = NSLocalizedString("costumemaster.ui.about_back", comment: "Back to menu")
        }
    }

    /// Listen for any clicks and respond when the user presses the back button.
    override func mouseDown(with event: NSEvent) {
        let tapped = event.location(in: self)

        if atPoint(tapped) == backButton {
            goBack()
        }
    }

    /// Listen for keyboard events and go back when the user presses the escape key.
    override func keyDown(with event: NSEvent) {
        let keycode = Int(event.keyCode)
        if keycode == KeyboardShortcuts.Shortcut(.escape).carbonKeyCode {
            goBack()
        }
    }
}
