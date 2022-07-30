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

struct PrefPaneGeneral: View {

    @AppStorage("cameraScale")
    var cameraScale: Double = 0.5

    @AppStorage("intelligentCameraMovement")
    var intelligentCameraMovement: Bool = true

    @AppStorage("usePhysicsMovement")
    var usePhysicsMovement: Bool = true

    @AppStorage("showDustParticles")
    var showDustParticles: Bool = true

    @AppStorage("dockIconName")
    var appIcon: AppIconKind = .standard

    @AppStorage("advShowUnmodeledOnMenu")
    var unmodeled: Bool = false

    @State private var canShowUnmodeled: Bool = UserDefaults.canShowUnmodeled

    @State private var iconSize: CGFloat = 64

    enum AppIconKind: String {
        case standard = "AppIcon"
        case unzipped = "AppIconUnzipped"
        case watchYourStep = "AppIconDLC"
        case machineLearning = "AppIconML"
    }

    private func appIconOption(for option: AppIconKind, help tooltipText: String) -> some View {
        VStack {
            Image(option.rawValue + "Representable")
                .resizable()
                .scaledToFill()
                .frame(width: iconSize, height: iconSize)
        }
            .tag(option)
            .overlay(Tooltip(tooltip: tooltipText))
    }

    var body: some View {
        VStack(spacing: 16) {
            Slider(
                value: $cameraScale,
                in: 0.25...1.0,
                step: 0.25,
                minimumValueLabel: Image("largecircle.fill.circle"),
                maximumValueLabel: Image("smallcircle.fill.circle")
            ) { Text("Camera scale") }
            VStack(alignment: .leading) {
                Toggle(isOn: $intelligentCameraMovement) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Move player camera intelligently")
                        Text("The camera will move based on how far the player has moved instead of putting the player"
                            + " at the center of the camera.")
                            .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $usePhysicsMovement) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use physics-based movement")
                        Text("Player controls will use physics-based calculations. Turning this off will move the " +
                             "player, regardless of physics forces.")
                        .foregroundColor(.secondary)
                    }
                }

                Divider()

                Toggle(isOn: $showDustParticles) {
                    Text("Display dust particles in environment when playing")
                }
                if canShowUnmodeled {
                    Toggle(isOn: $unmodeled) { Text("Show character on main menu with face reveal") }
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Picker(selection: $appIcon.onChange { icon in
                    AppDelegate.updateDockTile(icon.rawValue)
                }, label: Text("Dock icon: ")) {
                    self.appIconOption(for: .standard, help: "Standard")
                    if UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility") {
                        self.appIconOption(for: .unzipped, help: "Unzipped")
                    }
                    self.appIconOption(for: .watchYourStep, help: "Watch Your Step!")
                    .disabled(
                        !UserDefaults.iapModule.bool(forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue)
                    )
                    self.appIconOption(for: .machineLearning, help: "Swiftly ML")
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                Text("While The Costumemaster is running, the Dock will display the selected icon.")
                    .foregroundColor(.secondary)
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
