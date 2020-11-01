//
//  AISimulatorConsoleToolbar.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/1/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, *)
/// A view that represents the console window's toolbar.
struct AISimulatorConsoleToolbar: View {

    /// The console model.
    @ObservedObject var console: ConsoleViewModel

    /// The body of the view.
    var body: some View {
        HStack {
            Button {
                self.console.clear()
            } label: {
                VStack {
                    Image("clear")
                        .font(.headline)
                    Text("Clear")
                        .font(.subheadline)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.trailing)
        .frame(maxWidth: .infinity)
    }
}

@available(OSX 10.15, *)
/// A preview container for the console toolbar.
struct AISimulatorConsoleToolbar_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorConsoleToolbar(console: ConsoleViewModel())
    }
}
