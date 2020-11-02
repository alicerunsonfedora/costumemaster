//
//  AIAbstractGameSignalSender.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//

import Foundation

/// An abstract data structure that represents an input device.
struct AIAbstractGameSignalSender {

    /// The position of the signal sender.
    var position: CGPoint

    /// The "pretty" or world position of the signal sender.
    var prettyPosition: CGPoint

    /// Whether the signal sender is active.
    var active: Bool

    /// The cooldown period for this signal sender.
    var timer: Int = -1

    /// A list of the positions that correspond to this signal sender's outputs.
    var outputs: [CGPoint]
}
