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

    override func viewDidAppear() {
        self.view.window?.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "MainMenu") {

            // swiftlint:disable:next force_cast
            if let sceneNode = scene.rootNode as! MainMenuScene? {
                // Present the scene
                if let view = self.skView {
                    view.presentScene(sceneNode)

                    view.ignoresSiblingOrder = true

                    view.showsFPS = true
                    view.showsNodeCount = true
                    view.shouldCullNonVisibleNodes = true
                }
            }
        }
    }
}
