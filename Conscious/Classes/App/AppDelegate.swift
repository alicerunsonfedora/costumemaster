//
//  AppDelegate.swift
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
import GameKit
import KeyboardShortcuts
import StoreKit

#if canImport(SwiftUI)
import SwiftUI
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// A global instance of the preferences.
    /// Ony preference panes will really update this field.
    static var preferences = Preferences()

    /// The arguments passed with the application.
    static var arguments: CommandLineArguments = CommandLine.parse()

    /// The window controller that corresponds to the preferences pane.
    private lazy var preferencesWindowController: NSWindowController? = {
        let storyboard: NSStoryboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
            return storyboard.instantiateInitialController() as? NSWindowController
    }()

    /// Open the preferences window.
    @IBAction func instantiatePreferencesWindow(_ sender: Any) {
        self.preferencesWindowController?.showWindow(self)
    }

    @IBAction func clearStore(_ sender: Any) {
        confirm(
            "Clearing the game store will reset your statistics and clear your current game session's save data. This "
            + "will not affect your achievements and leaderboards in Game Center. This action cannot be undone.",
            withTitle: "Clear Game Store?",
            level: .warning
        ) { response in
            if response.rawValue != 1000 { return }
            GameStore.shared.clear()
        }
    }

    @IBAction func showAbout(_ sender: Any) {
        GameManagerDelegate.loadScene(with: "About", keepHistory: true)
    }

    @IBAction func startGame(_ sender: Any) {
        GameManagerDelegate.startGame()
    }

    @IBAction func resumeGame(_ sender: Any) {
        GameManagerDelegate.resumeGame()
    }

    @IBAction func callMainMenu(_ sender: Any) {
        GameManagerDelegate.callMainMenu()
    }

    @IBAction func showGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/alicerunsonfedora/CS400/issues/new")!)
    }

    @IBAction func showDocumentation(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://costumemaster.marquiskurt.net")!)
    }

    @IBAction func restorePurchases(_ sender: Any) {
        IAPObserver.shared.restore()
    }

    @IBAction func openSimulator(_ sender: Any) {
        if #available(OSX 10.15, *) {
            let hostingController = NSApplication.shared.mainWindow?.contentViewController
            let viewController = NSViewController()
            let hostingView = NSHostingView(rootView: AISimulatorView { agentType, level, budget in
                hostingController?.dismiss(viewController)
                self.runAgentSimulation(agentType, level.rawValue, budget)
            })
            viewController.view = hostingView
            viewController.title = "AI Simulator"
            hostingController?.presentAsModalWindow(viewController)
        }
    }

    @IBAction func openSimulatorConsole(_ sender: Any) {
        if #available(OSX 10.15, *) {
            if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
                if let view = controller.view as? SKView {
                    if let scene = view.scene as? AIGameScene {
                        scene.initConsole()
                        scene.console.info("Restored console window.")
                    } else {
                        sendAlert(
                            "The simulator console is only available when running an AI simulation.",
                            withTitle: "Please run a simulation.",
                            level: .informational) { _ in }
                    }
                }
            }
        }
    }

    func authenticateWithGameCenter() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (viewC: NSViewController?, error) in
            guard error == nil else { return }

            if let controller = viewC {
                NSApplication.shared.mainWindow?.contentViewController?.presentAsSheet(controller)
            }
        }
    }

    func runAgentSimulation(_ agentType: CommandLineArguments.AgentTestingType, _ level: String, _ budget: Int) {
        AppDelegate.arguments = CommandLine.parse(
            [
                "--agent-test-mode", "true",
                "--agent-type", agentType.rawValue,
                "--agent-move-rate", "\(budget)"
            ]
        )
        GameManagerDelegate.loadScene(with: level + "AI", keepHistory: true, fadeDuration: 3.0)
        GameManagerDelegate.canRunSimulator = false
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        GameManagerDelegate.canRunSimulator = true
        DispatchQueue.main.async {
            SKPaymentQueue.default().add(IAPObserver.shared)
            IAPManager.shared.makeAllProductRequests()

            // Authenticate with Game Center if we're in AI mode. This helps de-clutter the print log and prevents
            // players from using AI agents to earn achievements/leaderboards for them.
            if !AppDelegate.arguments.useAgentTesting {
                self.authenticateWithGameCenter()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DispatchQueue.main.async {
            SKPaymentQueue.default().remove(IAPObserver.shared)
        }
    }

}
