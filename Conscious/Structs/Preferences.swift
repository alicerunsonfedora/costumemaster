//
//  Preferences.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure that represents the preferences in the game using the standard user defaults.
struct Preferences {

    /// Whether the preferences are being initialized.
    ///
    /// This is typically used to prevent double-writing of user defaults.
    private var initCall: Bool = false

    // MARK: GENERAL
    /// The scale of the camera size for the levels.
    public var cameraScale: Float {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(cameraScale, forKey: "cameraScale")
            }
        }
    }

    // MARK: SOUND
    /// The volume at which the music should play.
    public var musicVolume: Float {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(musicVolume, forKey: "soundMusicVolume")
            }
        }
    }

    /// Whether to play the costume changing sound.
    public var playChangeSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playChangeSound, forKey: "soundPlayChangeNoise")

            }
        }
    }

    /// Whether to play the computer turn-on sound.
    public var playComputerSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playComputerSound, forKey: "soundPlayComputerNoise")

            }
        }
    }

    /// Whether to play the lever toggle sound.
    public var playLeverSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playLeverSound, forKey: "soundPlayLeverNoise")

            }
        }
    }

    /// Whether to play the alarm clock enable/disable sound.
    ///
    /// This setting does _not_ control the sound for the ticks while the alarm is active.
    public var playAlarmSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playAlarmSound, forKey: "soundPlayAlarmNoise")

            }
        }
    }

    // MARK: ADVANCED PROPERTIES
    /// Whether the player can see the main character with the USB costume partially undone on the main menu.
    ///
    /// This preference is enabled after earning the _Face Reveal_ achievement.
    public var canShowUnmodeledOnMenu: Bool {
        return UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility")
    }

    /// Whether to show the main character with the USB costume partially undone.
    public var showUnmodeledOnMenu: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showUnmodeledOnMenu, forKey: "advShowUnmodeledOnMenu")
            }
        }
    }

    // MARK: DEBUGGING PROPERTIES
    /// Whether to show the number of nodes in the debugging screen.
    public var showNodeCount: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showNodeCount, forKey: "debugShowNodeCount")
            }
        }
    }

    /// Whether to show the number of frames per second in the debugging screen.
    public var showFramesPerSecond: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showFramesPerSecond, forKey: "debugShowFPS")
            }
        }
    }

    /// Whether to show the outlines of physics bodies in the debugging screen.
    public var showPhysicsBodies: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showPhysicsBodies, forKey: "debugShowPhysics")
            }
        }
    }

    /// Instantiate the preferences.
    /// 
    /// Default values are assigned if no values exist.
    init() {
        self.initCall = true
        let prefs = UserDefaults.standard
        if prefs.value(forKey: "cameraScale") == nil {
            prefs.setValue(0.75, forKey: "cameraScale")
        }
        if prefs.value(forKey: "soundMusicVolume") == nil {
            prefs.setValue(0.5, forKey: "soundMusicVolume")
        }
        self.cameraScale = prefs.float(forKey: "cameraScale")
        self.musicVolume = prefs.float(forKey: "soundMusicVolume")

        for pref in ["soundPlayChangeNoise", "soundPlayLeverNoise", "soundPlayComputerNoise", "soundPlayAlarmNoise"] {
            if prefs.value(forKey: pref) == nil {
                prefs.setValue(true, forKey: pref)
            }
        }

        self.playChangeSound = prefs.bool(forKey: "soundPlayChangeNoise")
        self.playLeverSound = prefs.bool(forKey: "soundPlayLeverNoise")
        self.playComputerSound = prefs.bool(forKey: "soundPlayComputerNoise")
        self.playAlarmSound = prefs.bool(forKey: "soundPlayAlarmNoise")

        for pref in ["advShowUnmodeledOnMenu", "debugShowNodeCount", "debugShowFPS", "debugShowPhysics"] {
            if prefs.value(forKey: pref) == nil {
                prefs.setValue(false, forKey: pref)
            }
        }

        self.showUnmodeledOnMenu = prefs.bool(forKey: "advShowUnmodeledOnMenu")
        self.showNodeCount = prefs.bool(forKey: "debugShowNodeCount")
        self.showFramesPerSecond = prefs.bool(forKey: "debugShowFPS")
        self.showPhysicsBodies = prefs.bool(forKey: "debugShowPhysics")

        self.initCall = false
    }
}
