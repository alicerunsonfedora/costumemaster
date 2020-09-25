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
import KeyboardShortcuts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// A global instance of the preferences.
    /// Ony preference panes will really update this field.
    static var preferences = Preferences()

    /// Open the preferences window.
    @IBAction func instantiatePreferencesWindow(_ sender: Any) {
        let prefs = NSStoryboard.init(name: NSStoryboard.Name("Preferences"), bundle: nil)
        guard let controller: NSWindowController = prefs.instantiateController(
                withIdentifier: "mainWindowController"
        ) as? NSWindowController else {
            return
        }
        controller.window?.parent = NSApplication.shared.mainWindow
        controller.showWindow(self)
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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
