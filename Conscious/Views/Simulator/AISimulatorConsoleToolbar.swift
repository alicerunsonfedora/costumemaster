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

import SwiftUI

/// A view that represents the console window's toolbar.
struct AISimulatorConsoleToolbar: View {
    /// The console model.
    @ObservedObject var console: ConsoleViewModel

    /// The filter to apply to all console messages
    @State var filter: FilterType = .allMessages

    /// An enumeration that represents the different filters for the console.
    enum FilterType: String, CaseIterable {
        /// All types of messages are allowed.
        case allMessages = "costumemaster.ai_console.level_all"

        /// Only info messages are allowed.
        case infoOnly = "costumemaster.ai_console.level_info"

        /// Only debugging messages are allowed.
        case debugOnly = "costumemaster.ai_console.level_debug"

        /// Only errors and warnings are allowed.
        case errorsAndWarningsOnly = "costumemaster.ai_console.level_error"
    }

    /// The body of the view.
    var body: some View {
        HStack {
            Picker("", selection: $filter.onChange(self.changeFilter)) {
                ForEach(FilterType.allCases, id: \.self) { type in
                    Text(NSLocalizedString(type.rawValue, comment: "Console message level"))
                }
            }
            HStack(spacing: 0) {
                Button { self.console.nowMode.toggle() }
                    label: {
                        Image("arrow.up.backward.circle\(self.console.nowMode ? ".fill" : "")")
                            .foregroundColor(self.console.nowMode ? .accentColor : Color(.controlTextColor))
                            .help("costumemaster.ai_console.now_help")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                Button { self.console.clear() }
                    label: {
                        Image("clear")
                            .help("costumemaster.ai_console.clear_help")
                    }
                    .buttonStyle(ToolbarButtonStyle())
            }
        }
        .padding(.trailing)
        .frame(maxWidth: .infinity)
    }

    /// Change the console filter.
    func changeFilter(_ type: FilterType) {
        switch type {
        case .infoOnly:
            console.filter = [.info]
        case .debugOnly:
            console.filter = [.debug]
        case .errorsAndWarningsOnly:
            console.filter = [.warning, .error]
        default:
            console.filter = [.info, .warning, .debug, .error, .unknown, .success]
        }
    }
}

/// A preview container for the console toolbar.
struct AISimulatorConsoleToolbar_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorConsoleToolbar(console: ConsoleViewModel())
    }
}
