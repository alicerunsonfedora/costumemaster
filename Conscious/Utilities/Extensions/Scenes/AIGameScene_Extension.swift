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
import SwiftUI

extension AIGameScene {
    private func getConsoleWindow() -> some View {
        AISimulatorConsole(console: console)
    }

    /// Initialize the console window and begin streaming information to the console view model.
    func initConsole() {
        // If we already initialized the console, just bring the window forward. There is no need to create a new
        // console window.
        if consoleWindowController != nil {
            consoleWindowController?.window?.orderFront(self)
            return
        }

        // Get the name of the level and change it accordingly.
        var name = name ?? "AI Level"
        if name.hasSuffix("AI") {
            name = String(name.dropLast(name.suffix(2).count))
        }

        let host = NSHostingView(rootView: getConsoleWindow())
        let viewController = NSViewController()
        viewController.view = host
        viewController.title = "AI Simulator Console"

        // Create the window that the console will live in and the appropriate interface changes such as
        // dark mode.
        let window = NSWindow(contentViewController: viewController)
        window.styleMask.insert(.unifiedTitleAndToolbar)
        window.appearance = NSAppearance(named: .darkAqua)
        window.toolbar = NSToolbar()

        window.title = "AI Simulator Console"
        window.subtitle = name

        // Create the hosting view for the toolbar buttons.
        let toolbarButtons = NSHostingView(
            rootView: AISimulatorConsoleToolbar(console: console)
        )
        toolbarButtons.frame.size = toolbarButtons.fittingSize

        // Create the appropriate toolbar accessories for the title and the toolbar buttons.
        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = toolbarButtons
        accessory.layoutAttribute = .trailing

        // Create a toolbar on the window and add the accessories.
        window.toolbar?.sizeMode = .regular
        window.addTitlebarAccessoryViewController(accessory)
        window.setContentSize(host.fittingSize)

        // Show the window and try to make it the key window.
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)

        consoleWindowController = windowController
    }

    /// Run any post-update logic and check input states.
    func aiFinish() {
        for input in switches where input.activationMethod.contains(.activeByPlayerIntervention) {
            if [GameSignalKind.pressurePlate, GameSignalKind.trigger].contains(input.kind),
               !(input is GameIrisScanner)
            {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            } else if input is GameIrisScanner,
                      input.shouldActivateOnIntervention(with: self.playerNode, objects: self.interactables)
            {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            }
        }
        checkDoorStates()
        if exitNode?.active == true {
            exitNode?.receive(with: playerNode, event: nil) { _ in }
        }
        for child in structure.children where child is GameDeathPit {
            guard let pit = child as? GameDeathPit else { continue }
            if pit.shouldKill(self.playerNode), !self.playerDied {
                self.kill()
            }
        }
    }
}
