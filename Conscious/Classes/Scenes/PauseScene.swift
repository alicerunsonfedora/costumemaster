//
//  PauseScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/30/20.
//

import Foundation
import SpriteKit
import KeyboardShortcuts

class PauseScene: SKScene {

    var mainMenuButton: SKLabelNode?
    var optionsButton: SKLabelNode?
    var resumeButton: SKLabelNode?
    var restartButton: SKLabelNode?

    override func sceneDidLoad() {
        guard let mainMenu = self.childNode(withName: "mainMenuButton") as? SKLabelNode else { return }
        self.mainMenuButton = mainMenu
        self.mainMenuButton?.fontName = "Cabin Regular"

        guard let options = self.childNode(withName: "optionsButton") as? SKLabelNode else { return }
        self.optionsButton = options
        self.optionsButton?.fontName = "Cabin Regular"

        guard let resume = self.childNode(withName: "resumeButton") as? SKLabelNode else { return }
        self.resumeButton = resume
        self.resumeButton?.fontName = "Cabin Regular"

        guard let restart = self.childNode(withName: "restartButton") as? SKLabelNode else { return }
        self.restartButton = restart
        self.restartButton?.fontName = "Cabin Regular"
    }

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

    private func mainMenuAction() {
        if let scene = SKScene(fileNamed: "MainMenu") as? MainMenuScene {
            self.view?.presentScene(scene)
        }
    }

    private func optionsAction() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.instantiatePreferencesWindow(self)
        }
    }

    private func resumeAction() {
        self.removeFromParent()
    }

    private func restartAction() {
        if let restartedScene = SKScene(fileNamed: self.name ?? "GameScene") as? GameScene {
            self.view?.presentScene(restartedScene)
        }
    }

}
