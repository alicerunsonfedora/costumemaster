//
//  ControlsPrefsViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Cocoa
import KeyboardShortcuts

class ControlsPrefsViewController: PreferencesViewController {

    @IBOutlet weak var moveUpView: NSView!
    @IBOutlet weak var moveDownView: NSView!
    @IBOutlet weak var moveLeftView: NSView!
    @IBOutlet weak var moveRightView: NSView!
    @IBOutlet weak var nextCostumeView: NSView!
    @IBOutlet weak var previousCostumeView: NSView!
    @IBOutlet weak var useView: NSView!

    private let moveUpRecorder = KeyboardShortcuts.RecorderCocoa(
        for: .moveUp,
        onChange: ControlsPrefsViewController.stripModifiers(.moveUp)
    )
    private let moveDownRecorder = KeyboardShortcuts.RecorderCocoa(
        for: .moveDown,
        onChange: ControlsPrefsViewController.stripModifiers(.moveDown)
    )
    private let moveLeftRecorder = KeyboardShortcuts.RecorderCocoa(for: .moveLeft)
    private let moveRightRecorder = KeyboardShortcuts.RecorderCocoa(for: .moveRight)
    private let nextCostumeRecorder = KeyboardShortcuts.RecorderCocoa(for: .nextCostume)
    private let prevCostumeRecorder = KeyboardShortcuts.RecorderCocoa(for: .previousCostume)
    private let useRecorder = KeyboardShortcuts.RecorderCocoa(for: .use)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the recorders as subviews since KeyboardShortcuts doesn't support this behavior by default.
        moveUpView.addSubview(self.moveUpRecorder)
        moveDownView.addSubview(self.moveDownRecorder)
        moveLeftView.addSubview(self.moveLeftRecorder)
        moveRightView.addSubview(self.moveRightRecorder)
        nextCostumeView.addSubview(self.nextCostumeRecorder)
        previousCostumeView.addSubview(self.prevCostumeRecorder)
        useView.addSubview(self.useRecorder)
    }

    @IBAction func resetShortcuts(_ sender: Any?) {
        KeyboardShortcuts.resetAll()
    }

    /// Strip the modifiers from a shortcut and re-apply the shortcut.
    ///
    /// This is passed to the KeyboardShortcuts's shortcut recorder since a modifier key is required to set a shortcut.
    /// This only triggers when using the Control key (^) as the modifier.
    /// - Parameter name: The shortcut to strip the mofidier for.
    /// - Returns: A function that will strip the modifier.
    static func stripModifiers(_ name: KeyboardShortcuts.Name) ->
        (_ shortcut: KeyboardShortcuts.Shortcut?) -> Void {
        return { (_ short: KeyboardShortcuts.Shortcut?) in
            if short?.modifiers == [NSEvent.ModifierFlags.control] {
                let newShortcut: KeyboardShortcuts.Shortcut? = KeyboardShortcuts.Shortcut(short?.key ?? .f19)
                KeyboardShortcuts.setShortcut(newShortcut, for: name)
            }
        }
    }
}
