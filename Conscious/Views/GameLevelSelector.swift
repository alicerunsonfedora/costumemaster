//
//  GameLevelSelector.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/5/20.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A view that lets players select a level and play it.
@available(OSX 10.15, *)
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
                    Text("Select a level.")
                        .font(.title)
                        .bold()
                    Text("Select a level from one of the packs below.")
                }
//                Divider()
                List {
                    Section(header: Text("The Costumemaster")) {
                        ForEach(realData.filter { ent in !ent.isDownloadableContent }) { entry in
                            self.entryItem(entry)
                                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                    Section(header: Text("Watch Your Step")) {
                        ForEach(realData.filter { ent in ent.isDownloadableContent }) { entry in
                            self.entryItem(entry)
                                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                }
            } else {
                Text("There isn't any data available.")
            }
            Button { dismiss() }
                label: { Text("Close") }
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
            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(.headline)
                Text(entry.description)
                    .font(.subheadline)
            }
            Spacer()
            Button {
                onLevelSelect(entry.name)
            } label: {
                Text("Play")
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(
                        Color(.controlAccentColor)
                            .opacity(
                                canPlayLevel(with: entry) ? 1.0: 0.3
                            )
                    )
                    .foregroundColor(.black)
                    .cornerRadius(6.0)
                    .shadow(color: Color(.shadowColor), radius: 10, x: 0, y: 8)
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(!canPlayLevel(with: entry))
        }
    }
}

/// A preview of the level selector.
@available(OSX 10.15, *)
struct GameLevelSelector_Previews: PreviewProvider {
    static var previews: some View {
        GameLevelSelector(levels: [
            GameLevelItem(name: "Entry", description: "Where it all begins.", isDownloadableContent: false),
            GameLevelItem(name: "Consequences", description: "Think about them.", isDownloadableContent: true)
        ]) { name in print(name) }
        dismiss: { }
    }
}
