//
//  AdvancedPrefsViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation
import Cocoa

class AdvancedPrefsViewController: PreferencesViewController {

    private var prefs: Preferences = Preferences()

    @IBOutlet weak var nodeCountCheckbox: NSButton!
    @IBOutlet weak var frameCountCheckbox: NSButton!
    @IBOutlet weak var physicsCheckbox: NSButton!

    override func viewWillAppear() {
        self.prefs = Preferences()
        self.nodeCountCheckbox.state = prefs.showNodeCount ? .on : .off
        self.frameCountCheckbox.state = prefs.showFramesPerSecond ? .on : .off
        self.physicsCheckbox.state = prefs.showPhysicsBodies ? .on : .off

    }

    override func viewWillDisappear() {
        self.prefs.showNodeCount = self.nodeCountCheckbox.state == .on
        self.prefs.showFramesPerSecond = self.frameCountCheckbox.state == .on
        self.prefs.showPhysicsBodies = self.physicsCheckbox.state == .on
    }
}
