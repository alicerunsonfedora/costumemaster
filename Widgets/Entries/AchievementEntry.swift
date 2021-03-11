//
//  AchievementEntry.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 3/10/21.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WidgetKit

struct AchievementEntry: TimelineEntry {
    var date: Date
    var achievementId: GameAchievement

    var name: String {
        switch achievementId {
        case .faceReveal:
            return "Face Reveal"
        case .newBird:
            return "Learning to Fly"
        case .newSorceress:
            return "Thinking with Magic"
        case .endReveal:
            return "Underneath it All"
        case .quickfooted:
            return "Quickfooted"
        case .superliminal:
            return "It's About Perspective"
        case .overclocker:
            return "Overclocker"
        case .costumemastery:
            return "Costumemastery"
        case .cloned:
            return "Cut and Paste"
        case .visibility:
            return "Now You See Me"
        default:
            return "No achievement"
        }
    }
}
