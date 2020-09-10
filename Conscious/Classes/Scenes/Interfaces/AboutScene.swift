//
//  AboutScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/10/20.
//

import Foundation
import SpriteKit
import KeyboardShortcuts

class AboutScene: SKScene {

    var backButton: SKLabelNode?
    var title: SKLabelNode?
    var versionString: SKLabelNode?

    private func goHome() {
        if let controller = self.view?.window?.contentViewController as? ViewController {
            guard let home = SKScene(fileNamed: "MainMenu") else { return }
            self.view?.presentScene(controller.rootScene != nil ? controller.rootScene : home)
        }
    }

    override func sceneDidLoad() {
        // Reset the scale mode to fit accordingly.
        self.scaleMode = .aspectFill

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

        if let title = self.childNode(withName: "title") as? SKLabelNode {
            self.title = title
            self.title?.fontName = "Dancing Script Regular"
        }

        if let versionString = self.childNode(withName: "version") as? SKLabelNode {
            self.versionString = versionString
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                ?? "0.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            self.versionString?.text = "Version \(version) (Build \(build))"
        }

        if let back = self.childNode(withName: "back") as? SKLabelNode {
            self.backButton = back
        }
    }

    override func mouseDown(with event: NSEvent) {
        let tapped = event.location(in: self)

        if self.atPoint(tapped) == backButton {
            goHome()
        }
    }

    override func keyDown(with event: NSEvent) {
        let keycode = Int(event.keyCode)
        if keycode == KeyboardShortcuts.Shortcut(.escape).carbonKeyCode {
            goHome()
        }
    }

}
