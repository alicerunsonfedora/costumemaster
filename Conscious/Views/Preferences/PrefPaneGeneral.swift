//
//  PrefPaneGeneral.swift
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

struct PrefPaneGeneral: View {

    @AppStorageCompat("cameraScale")
    var cameraScale: Float = 0.5

    @AppStorageCompat("intelligentCameraMovement")
    var intelligentCameraMovement: Bool = true

    @AppStorageCompat("showDustParticles")
    var showDustParticles: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Slider(
                value: $cameraScale,
                in: 0.25...1.0,
                step: 0.25,
                minimumValueLabel: Image("largecircle.fill.circle"),
                maximumValueLabel: Image("smallcircle.fill.circle")
            ) { Text("Camera scale") }
            VStack(alignment: .leading) {
                Toggle(isOn: $intelligentCameraMovement) {
                    Text("Move player camera intelligently")
                }
                Text("The camera will move based on how far the player has moved instead of putting the player at the"
                     + " center of the camera.")
                    .foregroundColor(.secondary)
                Toggle(isOn: $showDustParticles) {
                    Text("Display dust particles in environment when playing")
                }
            }
        }
        .padding()
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PrefPaneGeneral_Previews: PreviewProvider {
    static var previews: some View {
        PrefPaneGeneral()
    }
}
