//
//  ViewController.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import SpriteKit
import GameplayKit
import GameKit

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet var skView: SKView!

    /// A private tunnled copy of AppDelegate's preferences.
    @available(*, deprecated, message: "Use static vars from UserDefaults instead.")
    private var settings: GamePreferences = AppDelegate.preferences

    /// The root scene for this controller.
    ///
    /// This is typically used when switching between scenes, but wanting to preserve the scene's state.
    /// Use this sparingly.
    var rootScene: SKScene?

    override func viewDidAppear() {
        self.view.window?.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        var shouldClose = false
        if self.skView.scene?.name == "MainMenu" {
            NSApplication.shared.terminate(self)
            return true
        }
        confirm("Any unsaved progress will be lost.",
                withTitle: "Are you sure you want to quit?",
                level: .warning) { resp in
            if resp.rawValue == 1000 {
                NSApplication.shared.terminate(self)
                shouldClose = true
            }
        }
        return shouldClose
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settings = GamePreferences()
        AppDelegate.arguments = CommandLine.parse()
        let interfaceScenes = ["MainMenu", "Splash", "Intro", "About", "PauseMenu", "End"]

        guard let dlcWatchYourStepLevels = plist(
                from: "LevelStructure")?.value(forKey: "WatchYourStep"
        ) as? [String?] else {
            return
        }

        var levelName = AppDelegate.arguments.startLevel ?? "Splash"

        if #available(OSX 10.15, *) {
            if levelName.hasSuffix("AI") && !AppDelegate.arguments.useAgentTesting {
                sendAlert(
                    "Run The Costumemaster with agent testing enabled via --agent-test-mode to run this level.",
                    withTitle: "You don't have permission to run \(levelName).",
                    level: .critical
                ) { _ in NSApplication.shared.terminate(nil) }
            }

            if AppDelegate.arguments.useAgentTesting && !interfaceScenes.contains(levelName)
                && !levelName.hasSuffix("AI") {
                levelName += "AI"
            }
        } else {
            sendAlert(
                "Ensure you are running the latest macOS version before running a map under Agent Testing Mode.",
                withTitle: "Your Mac is not compatible with Agent Testing Mode.",
                level: .critical
            ) { _ in NSApplication.shared.terminate(nil) }
        }

        if dlcWatchYourStepLevels.contains(levelName)
            && !UserDefaults.iapModule.bool(forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue) {
            sendAlert(
                "Please purchase the Watch Your Step DLC from within the game to run this level via the command line.",
                withTitle: "You don't have permission to play the level \(levelName).",
                level: .critical
            ) { _ in
                levelName = "Splash"
            }
        }

        guard let scene = GKScene(fileNamed: levelName) else {
            sendAlert(
                "Check that \(levelName) is installed properly. If the problem persists, please reinstall the game.",
                withTitle: "The scene \(levelName) is missing.",
                level: .critical
            ) { _ in NSApplication.shared.terminate(nil) }
            return
        }

        // swiftlint:disable:next force_cast
        guard let sceneNode = scene.rootNode as! SKScene? else {
            return
        }

        guard let view = self.skView else {
            return
        }

        view.presentScene(sceneNode)
        view.ignoresSiblingOrder = true
        view.showsFPS = UserDefaults.debugFPS
        view.showsNodeCount = UserDefaults.debugNode
        view.showsPhysics = UserDefaults.debugShowPhysics
        view.shouldCullNonVisibleNodes = true

    }

    override func viewWillAppear() {
//        self.authenticateWithGameCenter()
    }
}
