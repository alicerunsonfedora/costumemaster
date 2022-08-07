//
//  GameSignalKind.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration that represent the different kinds of inputs.
public enum GameSignalKind {
    /// A computer with the "T1" security lock.
    case computerT1

    /// A computer with the "T2" security lock.
    case computerT2

    /// A lever.
    case lever

    /// A trigger.
    case trigger

    /// An alarm clock.
    case alarmClock

    /// A pressure plate.
    case pressurePlate
}
