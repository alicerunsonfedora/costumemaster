//
//  PreferencesWindowController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//

import Foundation
import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.orderOut(sender)
        return false
    }

}
