//
//  AIAbstractGameSignalReceivable.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An abstract data structure that represents a signal receiver.
struct AIAbstractGameSignalReceivable {
    /// Whether the signal receiver is active.
    var active: Bool

    /// The position of the signal receiver.
    var location: CGPoint
}
