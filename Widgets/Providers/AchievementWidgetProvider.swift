//
//  AchievementWidgetProvider.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 3/11/21.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Intents
import WidgetKit

@available(OSX 11, *)
struct AchievementWidgetProvider: TimelineProvider {
    func placeholder(in _: Context) -> AchievementEntry {
        AchievementEntry(date: Date(), achievementId: .superliminal)
    }

    func getSnapshot(in _: Context, completion: @escaping (AchievementEntry) -> Void) {
        let entry = AchievementEntry(date: Date(), achievementId: getAchievementInStore())
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<AchievementEntry>) -> Void) {
        var entries: [AchievementEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 3 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = AchievementEntry(date: entryDate, achievementId: getAchievementInStore())
            entries.append(entry)
        }
        let newTimeline = Timeline(entries: entries, policy: .atEnd)
        completion(newTimeline)
    }

    private func getAchievementInStore() -> GameAchievement {
        let value: String? = UserDefaults(
            suiteName: "group.net.marquiskurt.costumemaster"
        )?.string(forKey: "lastAchievement")
        return GameAchievement(rawValue: value ?? "") ?? .none
    }
}
