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
import Preferences

#if canImport(SwiftUI)
import SwiftUI
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// The arguments passed with the application.
    static var arguments: CommandLineArguments = CommandLine.parse()

    /// The window controller that corresponds to the preferences pane.
    private lazy var preferencesWindowController: PreferencesWindowController = {
        let controller = PreferencesWindowController(
            panes: [
                Preferences.Pane(
                    identifier: .general,
                    title: "Appearance",
                    toolbarIcon: NSImage(named: "paintpalette")!
                ) { PrefPaneGeneral() },
                Preferences.Pane(
                    identifier: .sound,
                    title: "Sound",
                    toolbarIcon: NSImage(named: "speaker.wave.3.fill")!
                ) { PrefPaneSound() },
                Preferences.Pane(
                    identifier: .controls,
                    title: "Controls",
                    toolbarIcon: NSImage(named: "keyboard")!
                ) { PrefPaneControls() },
                Preferences.Pane(
                    identifier: .gameCenter,
                    title: "Game Center",
                    toolbarIcon: NSImage(named: "gamecontroller")!
                ) { PrefPaneGC() },
                Preferences.Pane(
                    identifier: .advanced,
                    title: "Advanced",
                    toolbarIcon: NSImage(named: "gearshape.2")!
                ) { PrefPaneAdvanced() }
            ]
        )
        controller.window?.appearance = NSAppearance(named: .darkAqua)
        return controller
    }()

    static func updateDockTile(_ iconName: String?) {
        let name = (iconName ?? "AppIcon") + "Representable"
        let dockTile = NSApplication.shared.dockTile
        if let icon = NSImage(named: name) {
            dockTile.contentView = NSImageView(image: icon)
            dockTile.display()
        }
    }

    static func showReloadedPrompt() {
        guard let sceneController = NSApplication.shared.mainWindow?.contentViewController else { return }
        let viewController = NSViewController()
        let reloadedView = ReloadedView { sceneController.dismiss(viewController) }
        viewController.view = NSHostingView(rootView: reloadedView)
        viewController.title = "Try The Costumemaster: Reloaded"
        sceneController.presentAsSheet(viewController)
    }

    /// Open the preferences window.
    @IBAction func instantiatePreferencesWindow(_ sender: Any) {
        preferencesWindowController.show()
    }

    @IBAction func clearStore(_ sender: Any) {
        confirm(
            NSLocalizedString("costumemaster.confirm.clear_store", comment: "Clear store confirmation"),
            withTitle: NSLocalizedString("costumemaster.confirm.clear_store_title", comment: "Clear game store title"),
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

    @IBAction func openLevel(_ sender: Any) {
        let viewController = NSViewController()
        let levelSelector = GameLevelSelector(levels: getLevelProperties()) { name in
            viewController.dismiss(self)
            GameManagerDelegate.loadScene(with: name, fadeDuration: 3.0)
        } dismiss: {
            viewController.dismiss(self)
        }
        let view = NSHostingView(rootView: levelSelector)
        viewController.view = view

        if let main = NSApplication.shared.mainWindow?.contentViewController {
            if main == self.preferencesWindowController.contentViewController {
                NSSound.beep()
                print("Preferences must be closed before opening a new level.")
                return
            }
            main.presentAsSheet(viewController)
        }
    }

    @IBAction func recordSimulation(_ sender: Any) {
        let viewController = NSViewController()
        let levelSelector = GameLevelSelector(levels: getRecordableLevelProperties()) { name in
            viewController.dismiss(self)

            let recordableName = name.replacingOccurrences(of: " ", with: "")

            GameManagerDelegate.loadRecording(with: recordableName)
        } dismiss: {
            viewController.dismiss(self)
        }
        let view = NSHostingView(rootView: levelSelector)
        viewController.view = view

        if let main = NSApplication.shared.mainWindow?.contentViewController {
            if main == self.preferencesWindowController.contentViewController {
                NSSound.beep()
                print("Preferences must be closed before starting a recording.")
                return
            }
            main.presentAsSheet(viewController)
            GameManagerDelegate.canRunSimulator = false
        }
    }

    @IBAction func callMainMenu(_ sender: Any) {
        GameManagerDelegate.callMainMenu()
    }

    @IBAction func showGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/alicerunsonfedora/costumemaster/issues/new")!)
    }

    @IBAction func showDocumentation(_ sender: Any) {
        NSApplication.shared.showHelp(sender)
    }

    @IBAction func restorePurchases(_ sender: Any) {
        IAPObserver.shared.restore()
    }

    @IBAction func showReloadedPromptFromMenu(_ sender: Any) {
        AppDelegate.showReloadedPrompt()
    }

    @IBAction func openSimulator(_ sender: Any) {
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

    @IBAction func openSimulatorConsole(_ sender: Any) {
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            if let view = controller.view as? SKView {
                if let scene = view.scene as? AIGameScene {
                    scene.initConsole()
                    scene.console.info("Restored console window.")
                } else {
                    sendAlert(
                        NSLocalizedString("costumemaster.alert.simulator_console_invalid_error", comment: "Simulator invalid error"),
                        withTitle: NSLocalizedString("costumemaster.alert.simulator_console_invalid_error_title", comment: "Simulator invalid error title"),
                        level: .informational) { _ in }
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
        AppDelegate.updateDockTile(UserDefaults.standard.string(forKey: "dockIconName"))
        GameManagerDelegate.canRunSimulator = true

        // NOTE: Use for migration of preferences.
        if UserDefaults.standard.value(forKey: "usePhysicsMovement") == nil {
            UserDefaults.standard.set(true, forKey: "usePhysicsMovement")
        }

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
