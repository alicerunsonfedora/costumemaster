//
//  GameTileType.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration for the different types of game tiles that the level can consist of.
public enum GameTileType {

    /// A player tile.
    case player

    /// A wall tile.
    case wall

    /// A door tile.
    case door

    /// A floor tile.
    case floor

    /// A lever tile.
    case lever

    /// A computer tile with the lock level "T1".
    case computerT1

    /// A computer tile with the lock level "T2".
    case computerT2

    /// An alarm clock tile.
    case alarmClock

    /// A pressure plate tile.
    case pressurePlate

    /// A heavy object tile.
    case heavyObject

    /// A Game Center trigger tile.
    case triggerGameCenter

    /// A kill trigger.
    case triggerKill

    /// A death pit.
    case deathPit

    /// An iris (biometric) scanner.
    case biometricScanner

    /// An unknown tile.
    case unknown
}
