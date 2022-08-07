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
            .help(tooltipText)
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Picker(selection: $appIcon.onChange { icon in
                    AppDelegate.updateDockTile(icon.rawValue)
                }, label: Text("costumemaster.settings.general_dock_icon_title")) {
                    self.appIconOption(
                        for: .standard,
                        help: NSLocalizedString(
                            "costumemaster.settings.general_dock_icon_default",
                            comment: "Standard"
                        )
                    )
                    if UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility") {
                        self.appIconOption(
                            for: .unzipped,
                            help: NSLocalizedString(
                                "costumemaster.settings.general_dock_icon_unzipped",
                                comment: "Unzipped"
                            )
                        )
                    }
                    self.appIconOption(
                        for: .watchYourStep,
                        help: NSLocalizedString(
                            "costumemaster.settings.general_dock_icon_dlc",
                            comment: "Watch Your Step!"
                        )
                    )
                        .disabled(
                            !UserDefaults.iapModule.bool(forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue)
                        )
                    self.appIconOption(
                        for: .machineLearning,
                        help: NSLocalizedString(
                            "costumemaster.settings.general_dock_icon_silicon",
                            comment: "Swiftly ML"
                        )
                    )
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                Text("costumemaster.settings.general_dock_icon_detail")
                    .foregroundColor(.secondary)
            }

            Divider()

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
                        Text("costumemaster.settings.general_camera_movement_title")
                        Text("costumemaster.settings.general_camera_movement_detail")
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                Toggle(isOn: $usePhysicsMovement) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("costumemaster.settings.general_player_physics_title")
                        Text("costumemaster.settings.general_player_physics_detail")
                        .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $showDustParticles) {
                    Text("costumemaster.settings.general_show_dust_title")
                }
                if canShowUnmodeled {
                    Toggle(isOn: $unmodeled) { Text("costumemaster.settings.general_show_unmodeled_title") }
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
