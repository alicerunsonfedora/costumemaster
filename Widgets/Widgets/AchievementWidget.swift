//
//  Costumemaster_Widgets.swift
//  Costumemaster Widgets
//
//  Created by Marquis Kurt on 3/10/21.
//

import Intents
import SwiftUI
import WidgetKit

@available(OSX 11, *)
struct AchievementWidget: Widget {
    let kind: String = "CSWidgetAchievement"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AchievementWidgetProvider()) { entry in
            AchievementView(entry: entry)
        }
        .configurationDisplayName("Latest Achievement")
        .description("Keep track of the latest achievements you earned.")
        .supportedFamilies([.systemSmall])
    }
}

@available(OSX 11, *)
struct AchievementWidgetPreview: PreviewProvider {
    static var previews: some View {
        AchievementView(entry: AchievementEntry(date: Date(), achievementId: .cloned))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
