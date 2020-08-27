//
//  AppDelegate.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
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
