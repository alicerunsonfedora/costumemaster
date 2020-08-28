//
//  GeneralPrefsViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation
import Cocoa

class GeneralPrefsViewController: PreferencesViewController {

    @IBOutlet weak var changeSoundCheckbox: NSButton!
    @IBOutlet weak var cameraScaleSlider: NSSlider!

    override func viewWillAppear() {
        self.changeSoundCheckbox.state = self.preferences.playChangeSound ? .on : .off
        self.cameraScaleSlider.doubleValue = Double(self.preferences.cameraScale * 100)
    }

    override func viewWillDisappear() {
        self.preferences.playChangeSound = self.changeSoundCheckbox.state == .on
        self.preferences.cameraScale = Float(self.cameraScaleSlider.doubleValue / 100)
    }

}
