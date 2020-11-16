//
//  AIStateRecordingToolbar.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct AIStateRecordingToolbar: View {
    @ObservedObject var journal: StateRecorderViewModel

    var body: some View {
        HStack {
            Button { promptSave() }
                label: {
                    Image("square.and.arrow.down")
                        .overlay(Tooltip(tooltip: "Export to CSV"))
                }
                .buttonStyle(ToolbarButtonStyle())
        }
        .padding(.trailing)
    }

    func promptSave() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["csv", "txt"]
        panel.allowsOtherFileTypes = true
        panel.message = "Select the destination to save the CSV file to."
        panel.titleVisibility = .hidden

        if panel.runModal() == NSApplication.ModalResponse.OK {
            journal.export(to: panel.url!)
        }
    }
}

struct AIStateRecordingToolbar_Previews: PreviewProvider {
    static var previews: some View {
        AIStateRecordingToolbar(
            journal: StateRecorderViewModel(from: makeDummyAssessment()) { _, _ in
                print("Stuff happened!")
            }
        )
        .frame(minHeight: 40)
    }
}

private func makeDummyAssessment() -> AIAbstractGameState.Assessement {
    AIAbstractGameState.Assessement(
        canEscape: false,
        nearExit: true,
        nearInput: false,
        inputActive: false,
        inputRelevant: false,
        requiresObject: false,
        requiresCostume: false,
        wearingCostume: false,
        hasObject: false,
        nearObject: false,
        allInputsActive: false
    )
}
