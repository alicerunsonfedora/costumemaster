//
//  UserDefaults.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension UserDefaults {

    static let cameraScale = UserDefaults.standard.float(forKey: "cameraScale")
    static let intelligentCamera = UserDefaults.standard.bool(forKey: "intelligentCameraMovement")
    static let dustParticles = UserDefaults.standard.bool(forKey: "showDustParticles")

    static let musicVolume = UserDefaults.standard.float(forKey: "soundMusicVolume")
    static let playChangeSound = UserDefaults.standard.bool(forKey: "soundPlayChangeNoise")
    static let playComputerSound = UserDefaults.standard.bool(forKey: "soundPlayComputerNoise")
    static let playLeverSound = UserDefaults.standard.bool(forKey: "soundPlayLeverNoise")
    static let playAlarmSound = UserDefaults.standard.bool(forKey: "soundPlayAlarmNoise")

    static let canShowUnmodeled = UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility")
    static let showUnmodeled = UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenu")

    static let debugNode = UserDefaults.standard.bool(forKey: "debugShowNodeSound")
    static let debugFPS = UserDefaults.standard.bool(forKey: "debugShowFPS")
    static let debugShowPhysics = UserDefaults.standard.bool(forKey: "debugShowPhysics")
}
