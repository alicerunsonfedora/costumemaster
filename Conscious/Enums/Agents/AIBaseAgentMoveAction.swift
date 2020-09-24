//
//  AIBaseAgentMoveAction.swift
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
enum AIBaseAgentMoveAction {
    
    // MARK: MOVEMENT
    /// Move the agent left.
    case moveLeft
    
    /// Move the agent right.
    case moveRight
    
    /// Move the agent up.
    case moveUp
    
    /// Move the agent down.
    case moveDown
    
    /// Stop all movement and/or action.
    case stop
    
    // MARK: COSTUMES
    
    /// Switch to the next costume the agent has.
    case switchToNextCostume
    
    /// Switch to the previous costume the agent has.
    case switchToPreviousCostume
    
    // MARK: ITEMS
    
    /// Pick up a heavy object.
    case pickup
    
    /// Drop a heavy object.
    case drop
    
    // MARK: OTHER
    
    /// Deploy a USB costume clone.
    case deployClone
    
    /// Retract a USB costume clone.
    case retractClone
    
    /// Activate an input.
    case activate
}
