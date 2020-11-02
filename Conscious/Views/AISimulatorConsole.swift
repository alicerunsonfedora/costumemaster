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
            List(console.messages) { message in
                HStack(spacing: 8) {
                    self.colorCoordinator(for: message.type)
                        .frame(width: 28)
                    Text(message.timestamp)
                        .font(.system(.body, design: .monospaced))
                    Text(message.contents)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listStyle(PlainListStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 500, minHeight: 200)
    }

    func colorCoordinator(for type: ConsoleViewModel.MessageType) -> some View {
        var color = Color.clear
        var imageName = ""

        switch type {
        case .info:
            color = .blue
            imageName = "info.circle.fill"
        case .warning:
            color = .yellow
            imageName = "exclamationmark.triangle"
        case .error:
            color = .red
            imageName = "xmark.octagon.fill"
        case .debug:
            color = .green
            imageName = "ant.circle.fill"
        default:
            color = .gray
            imageName = "questionmark"
        }

        return Image(imageName)
            .foregroundColor(color)
            .font(.body)
            .padding(6)
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
