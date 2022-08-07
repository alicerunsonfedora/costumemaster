//
//  PrefPaneControls.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import Combine
import KeyboardShortcuts

struct PrefPaneControls: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 32) {
                VStack(alignment: .trailing) {
                    self.shortcut(for: .moveUp) { Text("costumemaster.settings.controls_move_up") }
                    self.shortcut(for: .moveDown) { Text("costumemaster.settings.controls_move_down") }
                    self.shortcut(for: .moveLeft) { Text("costumemaster.settings.controls_move_left") }
                    self.shortcut(for: .moveRight) { Text("costumemaster.settings.controls_move_right") }
                }
                VStack(alignment: .trailing) {
                    self.shortcut(for: .nextCostume) { Text("costumemaster.settings.controls_next_costume") }
                    self.shortcut(for: .previousCostume) { Text("costumemaster.settings.controls_prev_costume") }
                }
                VStack(alignment: .trailing) {
                    self.shortcut(for: .use) { Text("costumemaster.settings.controls_use") }
                    self.shortcut(for: .pause) { Text("costumemaster.settings.controls_pause") }
                }
            }
            Text("costumemaster.settings.controls_detail")
                .foregroundColor(.secondary)
            HStack {
                Spacer()
                Button { KeyboardShortcuts.resetAll() }
                    label: {
                        Text("costumemaster.settings.controls_reset")
                    }
            }
        }
        .padding()
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func shortcut(for key: KeyboardShortcuts.Name, @ViewBuilder _ label: () -> Text) -> some View {
        return HStack {
            label()
            KeyboardShortcuts.Recorder(for: key) { iKey in
                PrefPaneControls.stripModifiers(.moveUp)(iKey)
            }
        }

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

struct PrefPaneControls_Previews: PreviewProvider {
    static var previews: some View {
        PrefPaneControls()
    }
}
