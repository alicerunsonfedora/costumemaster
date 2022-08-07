//
//  PrefPaneGC.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/12/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import GameKit
import SwiftUI

struct PrefPaneGC: View {
    @AppStorage("gcSubmitAchievements")
    var achievements: Bool = true

    @AppStorage("gcNotifications")
    var notifications: Bool = true

    @AppStorage("gcSubmitLeaderboardScores")
    var leaderboards: Bool = true

    @State private var playerImage: NSImage?

    func getPlayerName() -> String {
        if !GKLocalPlayer.local.isAuthenticated { return "Username" }
        return GKLocalPlayer.local.alias
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                if playerImage != nil {
                    Image(nsImage: playerImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                } else {
                    Image("gamecontroller")
                        .padding()
                        .font(.title)
                        .background(Color(.controlColor))
                        .clipShape(Circle())
                        .frame(width: 64, height: 64)
                }

                VStack(alignment: .leading) {
                    Text(getPlayerName())
                        .font(.system(.title, design: .rounded))
                        .bold()
                    Text("Game Center")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $achievements) {
                    Text("costumemaster.settings.gc_achievements")
                }
                Toggle(isOn: $leaderboards) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("costumemaster.settings.gc_leaderboards_title")
                        Text("costumemaster.settings.gc_leaderboards_detail")
                            .foregroundColor(.secondary)
                    }
                }
                Toggle(isOn: $notifications) {
                    Text("costumemaster.settings.gc_notifications")
                }
            }
        }
        .padding()
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.loadPhoto(for: .normal) { gameImage, error in
                    guard error == nil else { return }
                    playerImage = gameImage
                }
            }
        }
    }
}

struct PrefPaneGC_Previews: PreviewProvider {
    static var previews: some View {
        PrefPaneGC()
    }
}
