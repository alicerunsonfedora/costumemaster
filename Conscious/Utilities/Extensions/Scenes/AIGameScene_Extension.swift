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

    /// Initialize the console window.
    func initConsole() {
        var name = self.name ?? "AI Level"
        if name.hasSuffix("AI") {
            name = String(name.dropLast(name.suffix(2).count))
        }
        let host = NSHostingView(rootView: AISimulatorConsole(console: self.console))
        let viewController = NSViewController()
        viewController.view = host
        viewController.title = "AI Simulator Console"

        let window = NSWindow(contentViewController: viewController)
        window.styleMask.insert(.unifiedTitleAndToolbar)

        let toolbarButtons = NSHostingView(rootView: AISimulatorConsoleToolbar(console: self.console))
        toolbarButtons.frame.size = toolbarButtons.fittingSize

        let toolbarTitle = NSHostingView(
            rootView: VStack(alignment: .leading) {
                Text(window.title)
                    .font(.headline)
                Text(name)
                    .font(.subheadline)
            }.padding(.leading)
        )
        toolbarTitle.frame.size = toolbarTitle.fittingSize

        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = toolbarButtons
        accessory.layoutAttribute = .trailing

        let titleAccessory = NSTitlebarAccessoryViewController()
        titleAccessory.view = toolbarTitle
        titleAccessory.layoutAttribute = .leading

        window.toolbar = NSToolbar()
        window.addTitlebarAccessoryViewController(titleAccessory)
        window.addTitlebarAccessoryViewController(accessory)
        window.titleVisibility = .hidden

        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)
        windowController.window?.makeKey()
    }

}
