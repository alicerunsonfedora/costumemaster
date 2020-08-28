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

    override func viewWillAppear() {
        self.changeSoundCheckbox.state = self.preferences.playChangeSound ? .on : .off
    }

    override func viewWillDisappear() {
        self.preferences.playChangeSound = self.changeSoundCheckbox.state == .on
    }

}
