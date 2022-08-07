//
//  GameLevelSelector.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/5/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A view that lets players select a level and play it.
struct GameLevelSelector: View {
    /// The list of levels to choose from.
    @State var levels: [GameLevelItem]?

    /// A closure that runs when a level is selected.
    var onLevelSelect: (String) -> Void

    /// A closure that runs when the controller is dismissed.
    var dismiss: () -> Void

    /// Returns whether the player can play the given level.
    func canPlayLevel(with entry: GameLevelItem) -> Bool {
        if !entry.isDownloadableContent { return true }
        return UserDefaults.iapModule.bool(
            forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue
        )
    }

    /// The body of this view.
    var body: some View {
        VStack {
            if let realData = levels {
                VStack {
                    Text("costumemaster.dialog.load_title")
                        .font(.title)
                        .bold()
                    Text("costumemaster.dialog.load_detail")
                }
//                Divider()
                List {
                    Section(header: Text("costumemaster.dialog.load_pack_original")) {
                        ForEach(realData.filter { ent in !ent.isDownloadableContent }) { entry in
                            self.entryItem(entry)
                                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                    if !realData.filter { ent in ent.isDownloadableContent }.isEmpty {
                        Section(header: Text("costumemaster.dialog.load_pack_dlc")) {
                            ForEach(realData.filter { ent in ent.isDownloadableContent }) { entry in
                                self.entryItem(entry)
                                    .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                            }
                        }
                    }
                }
            } else {
                Text("costumemaster.dialog.load_no_data")
            }
            Button { dismiss() }
                label: { Text("costumemaster.dialog.load_dismiss_button") }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }

    /// Returns a view of the image for the level entry.
    func getImage(for entry: GameLevelItem) -> some View {
        entry.isDownloadableContent
            ? Image("WatchYourStep").resizable().scaledToFit().cornerRadius(6.0)
            : Image("AppIconRepresentable").resizable().scaledToFit().cornerRadius(0.01)
    }

    /// Returns a list entry for the entry given.
    func entryItem(_ entry: GameLevelItem) -> some View {
        HStack {
            getImage(for: entry)
                .frame(maxWidth: 32)
            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(.headline)
                Text(entry.description)
                    .font(.subheadline)
            }
            Spacer()
            if #available(macOS 12.0, *) {
                makeModernButton(for: entry)
                    .buttonStyle(.borderedProminent)
                    .disabled(!canPlayLevel(with: entry))
            } else {
                button(for: entry)
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(!canPlayLevel(with: entry))
            }
        }
    }

    @available(macOS 12.0, *)
    func makeModernButton(for entry: GameLevelItem) -> some View {
        Button {
            onLevelSelect(entry.name)
        } label: {
            Text("Play")
        }
    }

    @available(macOS, introduced: 11.0, deprecated: 12.0, message: "Use makeModernButton instead.")
    func button(for entry: GameLevelItem) -> some View {
        Button {
            onLevelSelect(entry.name)
        } label: {
            Text("Play")
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(
                    Color(.controlAccentColor)
                        .opacity(
                            canPlayLevel(with: entry) ? 1.0 : 0.3
                        )
                )
                .foregroundColor(.black)
                .cornerRadius(6.0)
                .shadow(color: Color(.shadowColor), radius: 10, x: 0, y: 8)
        }
    }
}

/// A preview of the level selector.
struct GameLevelSelector_Previews: PreviewProvider {
    static var previews: some View {
        GameLevelSelector(levels: [
            GameLevelItem(name: "Entry", description: "Where it all begins.", isDownloadableContent: false),
            GameLevelItem(name: "Consequences", description: "Think about them.", isDownloadableContent: true),
        ]) { name in print(name) }
        dismiss: {}
    }
}
