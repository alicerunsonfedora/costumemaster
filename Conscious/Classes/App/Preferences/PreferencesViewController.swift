//
//  PreferencesViewController.swift
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

class PreferencesViewController: NSViewController {

    var preferences: Preferences = Preferences()

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = self.title!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.preferredContentSize = NSSize(width: self.view.frame.width, height: self.view.frame.height)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        AppDelegate.preferences = preferences
    }
}
