//
//  PreferencesViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation
import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = self.title!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.preferredContentSize = NSSize(width: self.view.frame.width, height: self.view.frame.height)
    }
}
