//
//  Alerts.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Cocoa

/// Send an alert.
/// This a convenience utility to create an NSAlert with some properties.
/// - Parameter message: The message of the alert.
/// - Parameter withTitle: The title of the alert.
/// - Parameter level: The level of importance for the alert.
/// - Parameter handler: An escaping closure that handles the alert's response when given.
func sendAlert(_ message: String,
               withTitle: String?,
               level: NSAlert.Style,
               handler: @escaping ((NSApplication.ModalResponse) -> Void)) {
    let alert = NSAlert()
    alert.alertStyle = level
    alert.messageText = withTitle ?? "The Costumemaster"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")

    if let window = NSApplication.shared.mainWindow {
        alert.beginSheetModal(for: window, completionHandler: handler)
    } else {
        handler(alert.runModal())
    }
}

/// Send an alert.
/// This a convenience utility to create an NSAlert with some properties.
/// - Parameter message: The message of the alert.
/// - Parameter withTitle: The title of the alert.
/// - Parameter level: The level of importance for the alert.
/// - Parameter attachToMainWindow: Whether to attach the alert to the main window.
/// - Parameter handler: An escaping closure that handles the alert's response when given.
func sendAlert(_ message: String,
               withTitle: String?,
               level: NSAlert.Style,
               attachToMainWindow: Bool,
               handler: @escaping ((NSApplication.ModalResponse) -> Void)) {
    let alert = NSAlert()
    alert.alertStyle = level
    alert.messageText = withTitle ?? "The Costumemaster"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")

    if attachToMainWindow, let window = NSApplication.shared.mainWindow {
        alert.beginSheetModal(for: window, completionHandler: handler)
    } else {
        handler(alert.runModal())
    }
}

/// Send a confirmation alert.
/// This a convenience utility to create an NSAlert with some properties.
/// - Parameter message: The message of the alert.
/// - Parameter withTitle: The title of the alert.
/// - Parameter level: The level of importance for the alert.
/// - Parameter handler: An escaping closure that handles the alert's response when given.
func confirm(_ message: String,
             withTitle: String?,
             level: NSAlert.Style,
             handler: @escaping ((NSApplication.ModalResponse) -> Void)) {
    let alert = NSAlert()
    alert.alertStyle = level
    alert.messageText = withTitle ?? "The Costumemaster"
    alert.informativeText = message
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    if let window = NSApplication.shared.mainWindow {
        alert.beginSheetModal(for: window, completionHandler: handler)
    } else {
        handler(alert.runModal())
    }
}
