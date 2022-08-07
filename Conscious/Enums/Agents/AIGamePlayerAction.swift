//
//  AIGamePlayerAction.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/24/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration that represents the moves an agent can make.
public enum AIGamePlayerAction: String, CaseIterable {
    // MARK: - MOVEMENT

    /// Move the agent left.
    case moveLeft = "MOVE_LEFT"

    /// Move the agent right.
    case moveRight = "MOVE_RIGHT"

    /// Move the agent up.
    case moveUp = "MOVE_UP"

    /// Move the agent down.
    case moveDown = "MOVE_DOWN"

    /// Stop all movement and/or action.
    case stop = "STOP"

    /// Returns the cases specific to player movement.
    static func movement() -> [AIGamePlayerAction] { [.moveUp, .moveDown, .moveLeft, .moveRight, .stop] }

    // MARK: - COSTUMES

    /// Switch to the next costume the agent has.
    case switchToNextCostume = "NEXT_COSTUME"

    /// Switch to the previous costume the agent has.
    case switchToPreviousCostume = "PREV_COSTUME"

    // MARK: ITEMS

    /// Pick up a heavy object.
    case pickup = "PICK_UP"

    /// Drop a heavy object.
    case drop = "DROP"

    // MARK: - OTHER

    /// Deploy a USB costume clone.
    case deployClone = "DEPLOY"

    /// Retract a USB costume clone.
    case retractClone = "RETRACT"

    /// Activate an input.
    case activate = "ACTIVATE"
}
