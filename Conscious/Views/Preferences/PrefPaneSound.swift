//
//  PrefPaneSound.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct PrefPaneSound: View {

    @AppStorage("soundMusicVolume")
    var musicVolume: Double = 0.5

    @AppStorage("soundPlayChangeNoise")
    var costumeChange: Bool = true

    @AppStorage("soundPlayComputerNoise")
    var computer: Bool = true

    @AppStorage("soundPlayAlarmNoise")
    var alarm: Bool = true

    @AppStorage("soundPlayLeverNoise")
    var lever: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Slider(
                value: $musicVolume,
                in: 0...1.0,
                minimumValueLabel: Image("speaker.fill"),
                maximumValueLabel: Image("speaker.wave.3.fill")
            ) { Text("costumemaster.settings.sound_music_volume") }

            HStack(alignment: .top) {
                Text("costumemaster.settings.sound_sfx_title")
                VStack(alignment: .leading) {
                    Toggle(isOn: $costumeChange) { Text("costumemaster.settings.sound_sfx_change") }
                    Toggle(isOn: $computer) { Text("costumemaster.settings.sound_sfx_computer") }
                    Toggle(isOn: $alarm) { Text("costumemaster.settings.sound_sfx_alarm") }
                    Toggle(isOn: $lever) { Text("costumemaster.settings.sound_sfx_lever") }

                }
            }
        }
        .padding()
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PrefPaneSound_Previews: PreviewProvider {
    static var previews: some View {
        PrefPaneSound()
    }
}
