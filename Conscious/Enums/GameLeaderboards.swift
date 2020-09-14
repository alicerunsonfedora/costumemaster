//
//  GameLeaderboards.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// An enumeration for all possible leaderboards in the game.
enum GameLeaderboard: String {
    /// Daily Divergent Challenge: Complete the level **Divergent** as fast as you can.
    /// - **ID**: costumemaster.ld.divergent_daily
    case divergentDaily = "costumemaster.ld.divergent_daily"

    /// Daily Rushed Challenge: Complete the level **Rushed** as fast as you can.
    /// - **ID**: costumemaster.ld.rushed_daily
    case rushedDaily = "costumemaster.ld.rushed_daily"

    /// Daily Cycle Challenge: Complete the level **Cycle** as fast as you can.
    /// - **ID**: costumemaster.ld.cycle_daily
    case cycleDaily = "costumemaster.ld.cycle_daily"
}
