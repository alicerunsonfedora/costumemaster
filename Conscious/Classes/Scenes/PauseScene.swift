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

    override func keyDown(with event: NSEvent) {
        if Int(event.keyCode) == KeyboardShortcuts.getShortcut(for: .pause)?.carbonKeyCode {
            self.resumeAction()
        }
    }

    private func mainMenuAction() {
        confirm("You'll lose any unsaved progress.", withTitle: "Go back to menu?", level: .warning) { resp in
            if resp.rawValue != 1000 { return }
            if let scene = SKScene(fileNamed: "MainMenu") as? MainMenuScene {
                self.view?.presentScene(scene)
            }
        }
    }

    private func optionsAction() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.instantiatePreferencesWindow(self)
        }
    }

    private func resumeAction() {
        if let controller = self.view?.window?.contentViewController as? ViewController {
            if controller.rootScene == nil { return }
            self.view?.presentScene(controller.rootScene!, transition: SKTransition.fade(withDuration: 0.10))
            controller.rootScene = nil
        }
    }

    private func restartAction() {
        confirm("You'll lose any unsaved progress.", withTitle: "Restart the level?", level: .warning) { resp in
            if resp.rawValue != 1000 { return }
            if let controller = self.view?.window?.contentViewController as? ViewController {
                if let scene = SKScene(fileNamed: controller.rootScene?.name ?? "") {
                    self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
                }
            }
        }
    }

}
