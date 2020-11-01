//
//  AISimulatorConsole.swift
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
/// A view that allows player to read console messages about a game scene.
struct AISimulatorConsole: View {

    /// The console model.
    @ObservedObject var console: ConsoleViewModel

    /// The body of the view.
    var body: some View {
        VStack(alignment: .leading) {
            List(console.messages, id: \.self) { message in
                Text(message)
                    .font(.system(.body, design: .monospaced))
            }
            .listStyle(PlainListStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 500, minHeight: 200)
    }
}

@available(OSX 10.15, *)
/// A preview container for the console window.
struct AISimulatorConsole_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorConsole(console: {
            let console = ConsoleViewModel()
            console.log("HELLO, WORLD!")
            console.log("Test message successfuly.")
            return console
        }())
    }
}
