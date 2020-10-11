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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// A global instance of the preferences.
    /// Ony preference panes will really update this field.
    static var preferences = Preferences()

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
        if let controller = NSApplication.shared.mainWindow?.contentViewController as? ViewController {
            if let view = controller.view as? SKView {
                guard let aboutScreen = SKScene(fileNamed: "About") else { return }
                if view.scene != nil { controller.rootScene = view.scene }
                view.presentScene(aboutScreen)
            }
        }
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

    func authenticateWithGameCenter() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (viewC: NSViewController?, error) in
            guard error == nil else { return }

            if let controller = viewC {
                NSApplication.shared.mainWindow?.contentViewController?.presentAsSheet(controller)
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        SKPaymentQueue.default().add(IAPObserver.shared)
        IAPManager.shared.makeAllProductRequests()
        self.authenticateWithGameCenter()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        SKPaymentQueue.default().remove(IAPObserver.shared)
    }

}
