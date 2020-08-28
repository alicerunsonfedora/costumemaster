//
//  Alerts.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
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
