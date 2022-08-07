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
        VStack(spacing: 8) {
            Image("reloaded_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
            Text("costumemaster.dialog.reload_title")
                .font(.system(.title3, design: .monospaced))
                .bold()
            Text("costumemaster.dialog.reload_detail")
                .lineLimit(10)
            Spacer()
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Text("costumemaster.dialog.reload_dismiss_button")
                }
                .keyboardShortcut(.cancelAction)
                Button(action: openStoreUrl) {
                    Text("costumemaster.dialog.reload_get_button")
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
        .frame(width: 300, height: 350)
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
