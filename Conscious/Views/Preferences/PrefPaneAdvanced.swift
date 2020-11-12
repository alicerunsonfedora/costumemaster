//
//  PrefPaneAdvanced.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import AppStorage

struct PrefPaneAdvanced: View {

    @AppStorageCompat("debugShowNodeCount")
    var nodeCount: Bool = false

    @AppStorageCompat("debugShowFPS")
    var fps: Bool = false

    @AppStorageCompat("debugShowPhysics")
    var physics: Bool = false

    @AppStorageCompat("advShowUnmodeledOnMenu")
    var unmodeled: Bool = false

    @State private var canShowUnmodeled: Bool = UserDefaults.canShowUnmodeled

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("Debug options: ")
                VStack(alignment: .leading) {
                    Toggle(isOn: $nodeCount) { Text("Show node count") }
                    Toggle(isOn: $fps) { Text("Show frames per second") }
                    Toggle(isOn: $physics) { Text("Show physics body outlines") }
                    Text("Debugging options take effect after restarting the game.")
                        .foregroundColor(.secondary)
                }
            }

            if canShowUnmodeled {
                Toggle(isOn: $unmodeled) { Text("Show character on main menu with face reveal") }
            }
        }
        .padding()
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PrefPaneAdvanced_Previews: PreviewProvider {
    static var previews: some View {
        PrefPaneAdvanced()
    }
}
