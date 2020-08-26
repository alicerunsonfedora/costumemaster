//
//  ViewController.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {

            // Get the SKScene from the loaded GKScene
            // swiftlint:disable:next force_cast
            if let sceneNode = scene.rootNode as! GameScene? {

                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .resizeFill

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
