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

import SwiftUI

/// A view that allows player to read console messages about a game scene.
struct AISimulatorConsole: View {
    /// The console model.
    @ObservedObject var console: ConsoleViewModel

    /// The body of the view.
    var body: some View {
        VStack(alignment: .leading) {
            if self.messageList.count > 150 {
                HStack {
                    Text("costumemaster.ai_console.performance_warn")
                    Spacer()
                    Button { self.console.clear() }
                        label: {
                            Text("costumemaster.ai_console.clear_button")
                                .foregroundColor(.primary)
                        }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.controlBackgroundColor))
            }
            List(self.messageList) { message in
                HStack(alignment: .top) {
                    self.colorCoordinator(for: message.type)
                        .frame(width: 28)
                        .padding(.leading, 4)
                    Text(message.timestamp)
                        .font(.system(.body, design: .monospaced))
                        .padding(.vertical, 4)
                    Text(message.contents)
                        .font(.system(.body, design: .monospaced))
                        .padding(.vertical, 4)
                }
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
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
        return console.nowMode ? history.reversed() : history
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
            color = Color(.systemIndigo)
            imageName = "ant"
        case .success:
            color = Color(.systemGreen)
            imageName = "checkmark.circle"
        default:
            color = .gray
            imageName = "questionmark"
        }

        return Image(imageName)
            .foregroundColor(color)
            .font(.body)
            .padding(4)
            .background(
                Circle()
                    .foregroundColor(Color(.controlBackgroundColor))
            )
    }
}

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
