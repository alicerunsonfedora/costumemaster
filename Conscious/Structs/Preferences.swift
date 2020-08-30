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

struct Preferences {

    private var initCall: Bool = false

    // MARK: GENERAL
    public var cameraScale: Float {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(cameraScale, forKey: "cameraScale")
            }
        }
    }

    // MARK: SOUND
    public var playChangeSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playChangeSound, forKey: "soundPlayChangeNoise")

            }
        }
    }

    public var playComputerSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playChangeSound, forKey: "soundPlayComputerNoise")

            }
        }
    }

    public var playLeverSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playChangeSound, forKey: "soundPlayLeverNoise")

            }
        }
    }

    // MARK: ADVANCED PROPERTIES
    public var canShowUnmodeledOnMenu: Bool {
        return UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenuAbility")
    }

    public var showUnmodeledOnMenu: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showUnmodeledOnMenu, forKey: "advShowUnmodeledOnMenu")
            }
        }
    }

    // MARK: DEBUGGING PROPERTIES
    public var showNodeCount: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showNodeCount, forKey: "debugShowNodeCount")
            }
        }
    }

    public var showFramesPerSecond: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showFramesPerSecond, forKey: "debugShowFPS")
            }
        }
    }

    public var showPhysicsBodies: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(showPhysicsBodies, forKey: "debugShowPhysics")
            }
        }
    }

    init() {
        self.initCall = true
        let prefs = UserDefaults.standard
        if prefs.value(forKey: "cameraScale") == nil {
            prefs.setValue(0.75, forKey: "cameraScale")
        }
        self.cameraScale = prefs.float(forKey: "cameraScale")

        for pref in ["soundPlayChangeNoise", "soundPlayLeverNoise", "soundPlayComputerNoise"] {
            if prefs.value(forKey: pref) == nil {
                prefs.setValue(true, forKey: pref)
            }
        }

        self.playChangeSound = prefs.bool(forKey: "soundPlayChangeNoise")
        self.playLeverSound = prefs.bool(forKey: "soundPlayLeverNoise")
        self.playComputerSound = prefs.bool(forKey: "soundPlayComputerNoise")

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
