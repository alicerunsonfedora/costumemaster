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
        self.showNodeCount = UserDefaults.standard.bool(forKey: "debugShowNodeCount")
        self.showFramesPerSecond = UserDefaults.standard.bool(forKey: "debugShowFPS")
        self.showPhysicsBodies = UserDefaults.standard.bool(forKey: "debugShowPhysics")
        self.playChangeSound = UserDefaults.standard.bool(forKey: "soundPlayChangeNoise")
        self.initCall = false
    }
}
