//
//  AdvancedpreferencesViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Cocoa

class AdvancedPrefsViewController: PreferencesViewController {

    @IBOutlet weak var unmodeledCheckbox: NSButton!
    @IBOutlet weak var nodeCountCheckbox: NSButton!
    @IBOutlet weak var frameCountCheckbox: NSButton!
    @IBOutlet weak var physicsCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        self.unmodeledCheckbox.state = preferences.showUnmodeledOnMenu ? .on : .off
        self.nodeCountCheckbox.state = preferences.showNodeCount ? .on : .off
        self.frameCountCheckbox.state = preferences.showFramesPerSecond ? .on : .off
        self.physicsCheckbox.state = preferences.showPhysicsBodies ? .on : .off

        self.unmodeledCheckbox.isHidden = !preferences.canShowUnmodeledOnMenu
    }

    override func viewWillDisappear() {
        self.preferences.showNodeCount = self.nodeCountCheckbox.state == .on
        self.preferences.showFramesPerSecond = self.frameCountCheckbox.state == .on
        self.preferences.showPhysicsBodies = self.physicsCheckbox.state == .on
        self.preferences.showUnmodeledOnMenu = self.unmodeledCheckbox.state == .on
    }
}
