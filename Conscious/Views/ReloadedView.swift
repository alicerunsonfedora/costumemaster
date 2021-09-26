//
//  ReloadedView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 26/9/21.
//

import SwiftUI

struct ReloadedView: View {

    var onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                Image("reloaded_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                VStack(alignment: .leading) {
                    Text("It's time to reload.")
                        .font(.system(.title, design: .monospaced))
                        .bold()
                    Text("The Costumemaster: Reloaded brings you the Costumemaster experience you love and more, "
                         + "with support for controllers, a brand new design with better graphics, localizations for "
                         + "Spanish and French, and other improvements.")
                }
                .padding(.top, 8)
            }
            .padding(.bottom)
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Text("Not Now")
                }
                .keyboardShortcut(.cancelAction)
                Button(action: openStoreUrl) {
                    Text("Get on the App Store")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(
            Image("reloaded_bg")
                .resizable()
                .scaledToFill()
        )
        .preferredColorScheme(.dark)
        .frame(width: 600)
    }

    func openStoreUrl() {
        NSWorkspace.shared.open(
            URL(string: "https://apps.apple.com/us/app/the-costumemaster-reloaded/id1573181569")!
        )
    }
}

struct ReloadedView_Previews: PreviewProvider {
    static var previews: some View {
        ReloadedView {
            print("Hi")
        }
    }
}
