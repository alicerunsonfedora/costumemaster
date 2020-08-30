//
//  Store.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//

import Foundation

/// A structure that represents the game's store data.
struct GameStore {

    /// A shared copy of the game store.
    static var shared: GameStore = GameStore()

    /// Whether the store is being initialized.
    private var inInit: Bool = false

    /// The last scene that was loaded before the game ended.
    public var lastSavedScene: String {
        didSet {
            if !inInit {
                UserDefaults.store.setValue(lastSavedScene, forKey: "lastSavedScene")
            }
        }
    }

    /// The number of times the player switched into the flash drive costume.
    public var costumeIncrementUSB: Int {
        didSet {
            if !inInit {
                UserDefaults.store.setValue(costumeIncrementUSB, forKey: "costumeIncrementUSB")
            }
        }
    }

    /// The number of times the player switched into the bird costume.
    public var costumeIncrementBird: Int {
        didSet {
            if !inInit {
                UserDefaults.store.setValue(costumeIncrementBird, forKey: "costumeIncrementBird")
            }
        }
    }

    /// The number of times the player switched into the sorceress costume.
    public var costumeIncrementSorceress: Int {
        didSet {
            if !inInit {
                UserDefaults.store.setValue(costumeIncrementSorceress, forKey: "costumeIncrementSorceress")
            }
        }
    }

    init() {
        self.inInit = true
        if UserDefaults.store.value(forKey: "lastSavedScene") == nil {
            UserDefaults.store.set("", forKey: "lastSavedScene")
        }
        self.lastSavedScene = UserDefaults.store.string(forKey: "lastSavedScene") ?? ""

        for increment in ["USB", "Bird", "Sorceress"] {
            if UserDefaults.store.value(forKey: "costumeIncrement\(increment)") == nil {
                UserDefaults.store.setValue(0, forKey: "costumeIncrement\(increment)")
            }
        }
        self.costumeIncrementUSB = UserDefaults.store.integer(forKey: "costumeIncrementUSB")
        self.costumeIncrementBird = UserDefaults.store.integer(forKey: "costumeIncrementBird")
        self.costumeIncrementSorceress = UserDefaults.store.integer(forKey: "costumeIncrementSorceress")
        self.inInit = false
    }
}

extension UserDefaults {
    /// The game's stored data.
    static var store: UserDefaults {
        return UserDefaults(suiteName: "net.marquiskurt.costumemaster_store")!
    }
}
