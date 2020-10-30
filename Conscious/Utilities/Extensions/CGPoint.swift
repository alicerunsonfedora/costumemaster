//
//  CGPoint.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension CGPoint {

    /// Returns the Manhattan or city-block distance between two points.
    /// - Parameter first: The starting CGPoint
    /// - Parameter second: The destination CGPoint
    /// - Returns: A CGFloat rerpesenting the Manhattan distance between the two points.
    static func manhattanDistance(from first: CGPoint, to second: CGPoint) -> CGFloat {
        return abs(first.x - second.x) + abs(first.y - second.y)
    }

    /// Returns the Manhattan or city-block distance between two points.
    /// - Parameter point: The destination CGPoint from itself.
    /// - Returns: A CGFloat rerpesenting the Manhattan distance between the two points.
    func manhattanDistance(to point: CGPoint) -> CGFloat {
        return CGPoint.manhattanDistance(from: self, to: point)
    }

}
