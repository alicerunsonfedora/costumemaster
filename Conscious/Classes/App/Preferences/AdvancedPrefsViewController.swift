//
//  AdvancedpreferencesViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation
import Cocoa

class AdvancedPrefsViewController: PreferencesViewController {

    @IBOutlet weak var nodeCountCheckbox: NSButton!
    @IBOutlet weak var frameCountCheckbox: NSButton!
    @IBOutlet weak var physicsCheckbox: NSButton!

    override func viewWillAppear() {
        self.nodeCountCheckbox.state = preferences.showNodeCount ? .on : .off
        self.frameCountCheckbox.state = preferences.showFramesPerSecond ? .on : .off
        self.physicsCheckbox.state = preferences.showPhysicsBodies ? .on : .off

    }

    override func viewWillDisappear() {
        self.preferences.showNodeCount = self.nodeCountCheckbox.state == .on
        self.preferences.showFramesPerSecond = self.frameCountCheckbox.state == .on
        self.preferences.showPhysicsBodies = self.physicsCheckbox.state == .on
    }
}
