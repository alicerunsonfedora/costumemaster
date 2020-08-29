//
//  ControlsPrefsViewController.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
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

    private let moveUpRecorder = KeyboardShortcuts.RecorderCocoa(for: .moveUp)
    private let moveDownRecorder = KeyboardShortcuts.RecorderCocoa(for: .moveDown)
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
        KeyboardShortcuts.reset([.moveUp, .moveRight, .moveDown, .moveLeft, .nextCostume, .previousCostume, .use])
    }
}
