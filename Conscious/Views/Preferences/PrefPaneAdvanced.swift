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

struct PrefPaneAdvanced: View {

    @AppStorage("debugShowNodeCount")
    var nodeCount: Bool = false

    @AppStorage("debugShowFPS")
    var fps: Bool = false

    @AppStorage("debugShowPhysics")
    var physics: Bool = false

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
