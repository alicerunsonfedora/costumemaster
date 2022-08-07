//
//  GameLevelItem.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/5/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure that represents a game level item.
struct GameLevelItem: Codable, Identifiable {
    /// A unique ID for this item.
    let id = UUID()
    // swiftlint:disable:previous identifier_name

    /// The name of the level.
    let name: String

    /// A description of the level.
    let description: String

    /// Whether the level is part of a DLC.
    let isDownloadableContent: Bool

    /// A enumeration representing the coding keys.
    private enum CodingKeys: String, CodingKey {
        /// The name of the level.
        case name = "Title"

        /// A description of the level.
        case description = "Description"

        /// Whether the level is part of a DLC.
        case isDownloadableContent = "Is DLC"
    }
}
