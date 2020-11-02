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
    @State var filter: FilterType = .allMessages

    enum FilterType: String, CaseIterable {
        case allMessages = "All Messages"
        case infoOnly = "Info Messages"
        case debugOnly = "Debug Messages"
        case errorsAndWarningsOnly = "Errors and Warnings"
    }

    /// The body of the view.
    var body: some View {
        HStack {
            Picker("", selection: $filter.onChange(self.changeFilter)) {
                ForEach(FilterType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
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

    func changeFilter(_ type: FilterType) {
        switch type {
        case .infoOnly:
            console.filter = [.info]
        case .debugOnly:
            console.filter = [.debug]
        case .errorsAndWarningsOnly:
            console.filter = [.warning, .error]
        default:
            console.filter = [.info, .warning, .debug, .error, .unknown]
        }
    }
}

@available(OSX 10.15, *)
/// A preview container for the console toolbar.
struct AISimulatorConsoleToolbar_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorConsoleToolbar(console: ConsoleViewModel())
    }
}
