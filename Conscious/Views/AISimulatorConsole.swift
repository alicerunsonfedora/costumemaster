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

/// A view that allows player to read console messages about a game scene.
@available(OSX 10.15, *)
struct AISimulatorConsole: View {

    /// The console model.
    @ObservedObject var console: ConsoleViewModel

    /// The body of the view.
    var body: some View {
        VStack(alignment: .leading) {
            if self.messageList.count > 150 {
                HStack {
                    Text("The console stack's current size may cause performance issues.")
                    Spacer()
                    Button { self.console.clear() }
                        label: {
                            Text("Clear")
                                .foregroundColor(.primary)
                        }
                }
                .padding(8)
                .background(Color(.controlBackgroundColor))
            }
            List(self.messageList) { message in
                HStack(spacing: 8) {
                    self.colorCoordinator(for: message.type)
                        .frame(width: 28)
                        .padding(.leading, 4)
                    Text(message.timestamp)
                        .font(.system(.body, design: .monospaced))
                    Text(message.contents)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .listStyle(PlainListStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            minWidth: 450, idealWidth: 650, maxWidth: .infinity, minHeight: 150, idealHeight: 200, maxHeight: .infinity
        )
    }

    /// A list of the console's messages.
    var messageList: [ConsoleViewModel.Message] {
        let history = console.messages.filter { mes in console.filter.contains(mes.type) }
        return self.console.nowMode ? history.reversed() : history
    }

    /// The color-coded icon for the console message.
    func colorCoordinator(for type: ConsoleViewModel.MessageType) -> some View {
        var color = Color.clear
        var imageName = ""

        switch type {
        case .info:
            color = Color(.systemBlue)
            imageName = "info.circle"
        case .warning:
            color = Color(.systemYellow)
            imageName = "exclamationmark.triangle"
        case .error:
            color = Color(.systemRed)
            imageName = "xmark.circle"
        case .debug:
            color = Color(.systemGreen)
            imageName = "ant"
        default:
            color = .gray
            imageName = "questionmark"
        }

        return Image(imageName)
            .foregroundColor(color)
            .font(.body)
            .padding(7)
            .background(
                Circle()
                    .foregroundColor(Color(.controlBackgroundColor))
            )
    }
}

/// A preview container for the console window.
@available(OSX 10.15, *)
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
