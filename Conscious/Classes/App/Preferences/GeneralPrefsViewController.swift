//
//  GeneralPrefsViewController.swift
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

class GeneralPrefsViewController: PreferencesViewController {

    @IBOutlet weak var cameraScaleSlider: NSSlider!
    @IBOutlet weak var cameraIntelligentMove: NSButton!
    @IBOutlet weak var showDustParticles: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        self.cameraScaleSlider.doubleValue = Double(self.preferences.cameraScale * 100)
        self.cameraIntelligentMove.state = preferences.intelligentCameraMovement ? .on : .off
        self.showDustParticles.state = preferences.showDustParticles ? .on : .off
    }

    override func viewWillDisappear() {
        self.preferences.cameraScale = Float(self.cameraScaleSlider.doubleValue / 100)
        self.preferences.intelligentCameraMovement = cameraIntelligentMove.state == .on
        self.preferences.showDustParticles = showDustParticles.state == .on
    }

}
