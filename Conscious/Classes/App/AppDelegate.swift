//
//  AppDelegate.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import Cocoa
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
        controller.showWindow(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
