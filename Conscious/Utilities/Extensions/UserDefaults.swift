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

    // MARK: - General
    /// The scale zoom for the camera.
    static var cameraScale = UserDefaults.standard.float(forKey: "cameraScale")

    /// Whether to use intelligent camera movement.
    static var intelligentCamera = UserDefaults.standard.bool(forKey: "intelligentCameraMovement")

    /// Whether to display dust particles.
    static var dustParticles = UserDefaults.standard.bool(forKey: "showDustParticles")

    // MARK: - Sound
    /// The music volume.
    static var musicVolume = UserDefaults.standard.float(forKey: "soundMusicVolume")

    /// Whether to play the costume change sound.
    static var playChangeSound = UserDefaults.standard.bool(forKey: "soundPlayChangeNoise")

    /// Whether to play the computer turn on sound.
    static var playComputerSound = UserDefaults.standard.bool(forKey: "soundPlayComputerNoise")

    /// Whether to play the lever sound.
    static var playLeverSound = UserDefaults.standard.bool(forKey: "soundPlayLeverNoise")

    /// Whether to play the alarm dound.
    static var playAlarmSound = UserDefaults.standard.bool(forKey: "soundPlayAlarmNoise")

    // MARK: - Advanced
    /// Whether the player has the ability to use character attributes on the main menu.
    static var canShowUnmodeled = UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility")

    /// Whether to update character attributes.
    static var showUnmodeled = UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenu")

    /// Whether to display the node count.
    static var debugNode = UserDefaults.standard.bool(forKey: "debugShowNodeSound")

    /// Whether to display the frames per second.
    static var debugFPS = UserDefaults.standard.bool(forKey: "debugShowFPS")

    /// Whether to show the outlines of physics bodies.
    static var debugShowPhysics = UserDefaults.standard.bool(forKey: "debugShowPhysics")
}
