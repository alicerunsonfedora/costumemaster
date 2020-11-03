//
//  AIGameScene_Extension.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/1/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, *)
extension AIGameScene {

    /// Initialize the console window and begin streaming information to the console view model.
    func initConsole() {
        // Get the name of the level and change it accordingly.
        var name = self.name ?? "AI Level"
        if name.hasSuffix("AI") {
            name = String(name.dropLast(name.suffix(2).count))
        }

        // Create the hosting view for the console window from the SwiftUI view.
        let host = NSHostingView(rootView: AISimulatorConsole(console: self.console))
        let viewController = NSViewController()
        viewController.view = host
        viewController.title = "AI Simulator Console"

        // Create the window that the console will live in and the appropriate interface changes such as
        // dark mode.
        let window = NSWindow(contentViewController: viewController)
        window.styleMask.insert(.unifiedTitleAndToolbar)
        window.appearance = NSAppearance(named: .darkAqua)

        // Create the hosting view for the toolbar buttons.
        let toolbarButtons = NSHostingView(rootView: AISimulatorConsoleToolbar(console: self.console))
        toolbarButtons.frame.size = toolbarButtons.fittingSize

        // Create the hosting view for the title and subtitle view of the window.
        let toolbarTitle = NSHostingView(
            rootView: VStack(alignment: .leading) {
                Text(window.title)
                    .font(.headline)
                Text(name)
                    .font(.subheadline)
            }.padding(.leading)
        )
        toolbarTitle.frame.size = toolbarTitle.fittingSize

        // Create the appropriate toolbar accessories for the title and the toolbar buttons.
        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = toolbarButtons
        accessory.layoutAttribute = .trailing

        let titleAccessory = NSTitlebarAccessoryViewController()
        titleAccessory.view = toolbarTitle
        titleAccessory.layoutAttribute = .leading

        // Create a toolbar on the window and add the accessories.
        window.toolbar = NSToolbar()
        window.toolbar?.sizeMode = .regular
        window.addTitlebarAccessoryViewController(titleAccessory)
        window.addTitlebarAccessoryViewController(accessory)
        window.titleVisibility = .hidden
        window.setContentSize(host.fittingSize)

        // Show the window and try to make it the key window.
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)
        windowController.window?.makeKey()

        self.consoleWindowController = windowController
    }

}
