//
//  AIStateRecordingView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct AIStateRecordingView: View {

    @ObservedObject var journal: StateRecorderViewModel

    @State private var action: NextAction = .nothing

    private enum NextAction: String {
        case moveRandom = "MOVE_RANDOM"
        case moveExitCloser = "MOVE_EXIT_CLOSER"
        case moveInputCloser = "MOVE_INPUT_CLOSER"
        case moveObjectCloser = "MOVE_OBJ_CLOSER"
        case activate = "ACTIVATE"
        case switchCostume = "NEXT_COSTUME"
        case pickupObject = "PICK_UP"
        case drop = "DROP"
        case nothing = "STOP"
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Current assessment")
                .bold()
            Text(
                "Below is the assessment of the current game state. "
                + "The information provided should assist in making a decision."
            )
            List {
                Section(header: Text("Basic information")) {
                    self.entry(
                        "Can the agent escape?",
                        with: journal.currentAssessment.canEscape
                    )
                    self.entry(
                        "Are all of the necessary inputs active?",
                        with: journal.currentAssessment.allInputsActive
                    )
                    self.entry(
                        "Is the agent carrying a heavy object?",
                        with: journal.currentAssessment.hasObject
                    )
                }

                Section(header: Text("Nearby environment variables")) {
                    self.entry(
                        "Is the agent near the exit?",
                        with: journal.currentAssessment.nearExit
                    )
                    self.entry(
                        "Is the agent near an input?",
                        with: journal.currentAssessment.nearInput
                    )
                    self.entry(
                        "Is the agent near an object?",
                        with: journal.currentAssessment.nearObject
                    )
                }

                if journal.currentAssessment.nearInput {
                    Section(header: Text("About nearest input")) {
                        self.entry(
                            "Is the input active?",
                            with: journal.currentAssessment.inputActive
                        )
                        self.entry(
                            "Does the input link to exit?",
                            with: journal.currentAssessment.inputRelevant
                        )
                        self.entry(
                            "Does the input require a specific costume?",
                            with: journal.currentAssessment.requiresCostume
                        )
                        self.entry(
                            "Is the agent wearing the correct costume to activate this input?",
                            with: journal.currentAssessment.wearingCostume
                        )
                        self.entry(
                            "Does the input require a heavy object?",
                            with: journal.currentAssessment.requiresObject
                        )
                    }
                }

            }

            HStack {
                Picker(selection: $action, label: Text("Perform the following action: ")) {
                    Text("Move randomly")
                        .tag(NextAction.moveRandom)
                    Text("Move closer to the exit")
                        .tag(NextAction.moveExitCloser)
                    Text("Move closer to the nearest input")
                        .tag(NextAction.moveInputCloser)
                    Text("Move closer to the nearest object")
                        .tag(NextAction.moveObjectCloser)
                    Text("Activate the input")
                        .tag(NextAction.activate)
                    Text("Switch costumes")
                        .tag(NextAction.switchCostume)
                    Text("Pick up the nearest obbject")
                        .tag(NextAction.pickupObject)
                    Text("Drop the current object")
                        .tag(NextAction.drop)
                    Text("Do nothing")
                        .tag(NextAction.nothing)
                }
                Spacer()
                Button {
                    journal.currentAction = action.rawValue
                }
                    label: {
                        Text("Submit")
                    }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }

    func entry(_ property: String, with answer: Bool) -> some View {
        HStack {
            Text(property)
            Spacer()
            Image(answer ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(answer ? .green : .red)
        }
    }
}

struct AIStateRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        AIStateRecordingView(
            journal: StateRecorderViewModel(from: makeDummyAssessment()) { _, _ in
                print("Stuff happened!")
            }
        )
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
