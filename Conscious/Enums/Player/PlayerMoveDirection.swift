//
//  PlayerMoveDirection.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration for the different directions a player can move.
public enum PlayerMoveDirection {

    /// The direction "north".
    case north

    /// The direction "south".
    case south

    /// The direction "east".
    case east

    /// The direction "west".
    case west

    /// The direction associated with an agent's move action.
    /// - Parameter action: The action to get the direction of.
    /// - Returns: The corresponding direction for the action provided, or north if the action is invalid.
    static func mappedFromAction(_ action: AIGamePlayerAction) -> PlayerMoveDirection {
        switch action {
        case .moveUp:
            return .north
        case .moveDown:
            return .south
        case .moveLeft:
            return .west
        case .moveRight:
            return .east
        default:
            return .north
        }
    }
}
