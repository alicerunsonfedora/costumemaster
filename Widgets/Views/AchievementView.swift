//
//  AchievementView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 3/10/21.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import WidgetKit

struct AchievementView: View {
    var entry: AchievementEntry
    var body: some View {
        ZStack {
            Color("WidgetBackground")
                .ignoresSafeArea()
            Image(entry.achievementId.rawValue)
                .resizable()
                .scaledToFill()
            LinearGradient(
                gradient:
                Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text(entry.name)
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .lineLimit(2)
                    Text(entry.achievementId == .none ? "Go earn an achievement!" : "Latest achievement")
                        .font(.subheadline)
                        .lineLimit(2)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
        .colorScheme(.dark)
    }
}

struct AchievementViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            AchievementView(entry: .init(date: Date(), achievementId: .cloned))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .redacted(reason: .placeholder)
            AchievementView(entry: .init(date: Date(), achievementId: .none))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            AchievementView(entry: .init(date: Date(), achievementId: .faceReveal))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
