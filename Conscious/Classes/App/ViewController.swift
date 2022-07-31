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
        confirm(
            NSLocalizedString("costumemaster.confirm.quit", comment: "Confirm quit"),
                withTitle: NSLocalizedString("costumemaster.confirm.quit_title", comment: "Confirm quit title"),
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
        AppDelegate.arguments = CommandLine.parse()
        let interfaceScenes = ["MainMenu", "Splash", "Intro", "About", "PauseMenu", "End"]

        guard let dlcWatchYourStepLevels = plist(
                from: "LevelStructure")?.value(forKey: "WatchYourStep"
        ) as? [String?] else {
            return
        }

        var levelName = AppDelegate.arguments.startLevel ?? "Splash"

        if levelName.hasSuffix("AI") && !AppDelegate.arguments.useAgentTesting {
            sendAlert(
                NSLocalizedString("costumemaster.alert.load_ai_bad_ctx_error", comment: "AI loaded without AI context error"),
                withTitle: NSLocalizedString("costumemaster.alert.load_ai_bad_ctx_error_title", comment: "AI loaded with AI context error title"),
                level: .critical
            ) { _ in NSApplication.shared.terminate(nil) }
        }

        if AppDelegate.arguments.useAgentTesting && !interfaceScenes.contains(levelName)
            && !levelName.hasSuffix("AI") {
            levelName += "AI"
        }

        if dlcWatchYourStepLevels.contains(levelName)
            && !UserDefaults.iapModule.bool(forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue) {
            sendAlert(
                NSLocalizedString("costumemaster.alert.dlc_error", comment: "DLC Load error"),
                withTitle: NSLocalizedString("costumemaster.alert.load_ai_bad_ctx_error_title", comment: "DLC load error title"),
                level: .critical
            ) { _ in
                levelName = "Splash"
            }
        }

        guard let scene = GKScene(fileNamed: levelName) else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.level_missing_error", comment: "Level file not found."),
                withTitle: NSLocalizedString("costumemaster.alert.level_missing_error_title", comment: "Level file not found title"),
                level: .critical
            ) { _ in NSApplication.shared.terminate(nil) }
            return
        }

        guard let sceneNode = scene.rootNode as? SKScene? else {
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
}
