//
//  Preferences.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation

struct Preferences {

    private var initCall: Bool = false

    // MARK: SOUND
    public var playChangeSound: Bool {
        didSet {
            if !initCall {
                UserDefaults.standard.setValue(playChangeSound, forKey: "soundPlayChangeNoise")

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
        self.playChangeSound = UserDefaults.standard.bool(forKey: "soundPlayChangeNoise")
        self.showUnmodeledOnMenu = UserDefaults.standard.bool(forKey: "advShowUnmodeledOnMenu")
        self.showNodeCount = UserDefaults.standard.bool(forKey: "debugShowNodeCount")
        self.showFramesPerSecond = UserDefaults.standard.bool(forKey: "debugShowFPS")
        self.showPhysicsBodies = UserDefaults.standard.bool(forKey: "debugShowPhysics")
        self.initCall = false
    }
}
