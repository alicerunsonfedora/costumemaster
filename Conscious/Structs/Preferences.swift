//
//  Preferences.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation

struct Preferences {
    public var showNodeCount: Bool {
        didSet {
            UserDefaults.standard.setValue(showNodeCount, forKey: "debugShowNodeCount")
        }
    }

    public var showFramesPerSecond: Bool {
        didSet {
            UserDefaults.standard.setValue(showFramesPerSecond, forKey: "debugShowFPS")
        }
    }

    public var showPhysicsBodies: Bool {
        didSet {
            UserDefaults.standard.setValue(showPhysicsBodies, forKey: "debugShowPhysics")
        }
    }

    init() {
        self.showNodeCount = UserDefaults.standard.bool(forKey: "debugShowNodeCount")
        self.showFramesPerSecond = UserDefaults.standard.bool(forKey: "debugShowFPS")
        self.showPhysicsBodies = UserDefaults.standard.bool(forKey: "debugShowPhysics")
    }
}
