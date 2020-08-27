//
//  ViewController.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet var skView: SKView!

    private var settings: Preferences = Preferences()

    override func viewDidAppear() {
        self.view.window?.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settings = Preferences()

        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "MainMenu") {

            // swiftlint:disable:next force_cast
            if let sceneNode = scene.rootNode as! MainMenuScene? {
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = settings.showFramesPerSecond
                    view.showsNodeCount = settings.showNodeCount
                    view.showsPhysics = settings.showPhysicsBodies
                    view.shouldCullNonVisibleNodes = true
                }
            }
        }
    }
}
