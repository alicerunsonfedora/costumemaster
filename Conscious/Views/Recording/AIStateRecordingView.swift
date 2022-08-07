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
            Text("costumemaster.ai_record.current_title")
                .bold()
            Text("costumemaster.ai_record.current_detail")
                .foregroundColor(.secondary)
            List {
                Section(header: Text("costumemaster.ai_record.table_basic_header")) {
                    self.entry(
                        "costumemaster.ai_record.table_basic_escape",
                        with: journal.currentAssessment.canEscape
                    )
                    self.entry(
                        "costumemaster.ai_record.table_basic_inputs_active",
                        with: journal.currentAssessment.allInputsActive
                    )
                    self.entry(
                        "costumemaster.ai_record.table_basic_has_heavy",
                        with: journal.currentAssessment.hasObject
                    )
                }

                Section(header: Text("costumemaster.ai_record.table_env_header")) {
                    self.entry(
                        "costumemaster.ai_record.table_env_near_exit",
                        with: journal.currentAssessment.nearExit
                    )
                    self.entry(
                        "costumemaster.ai_record.table_env_near_input",
                        with: journal.currentAssessment.nearInput
                    )
                    self.entry(
                        "costumemaster.ai_record.table_env_near_object",
                        with: journal.currentAssessment.nearObject
                    )
                }

                if journal.currentAssessment.nearInput {
                    Section(header: Text("costumemaster.ai_record.table_input_header")) {
                        self.entry(
                            "costumemaster.ai_record.table_input_active",
                            with: journal.currentAssessment.inputActive
                        )
                        self.entry(
                            "costumemaster.ai_record.table_input_exit_link",
                            with: journal.currentAssessment.inputRelevant
                        )
                        self.entry(
                            "costumemaster.ai_record.table_input_requires_costume",
                            with: journal.currentAssessment.requiresCostume
                        )
                        self.entry(
                            "costumemaster.ai_record.table_input_wearing_costume",
                            with: journal.currentAssessment.wearingCostume
                        )
                        self.entry(
                            "costumemaster.ai_record.table_input_heavy_object",
                            with: journal.currentAssessment.requiresObject
                        )
                    }
                }

            }

            HStack {
                Picker(selection: $action, label: Text("costumemaster.ai_record.perform_title")) {
                    Text("costumemaster.ai_record.action_move_random")
                        .tag(NextAction.moveRandom)
                    Text("costumemaster.ai_record.action_move_exit")
                        .tag(NextAction.moveExitCloser)
                    Text("costumemaster.ai_record.action_move_input")
                        .tag(NextAction.moveInputCloser)
                    Text("costumemaster.ai_record.action_move_object")
                        .tag(NextAction.moveObjectCloser)
                    Text("costumemaster.ai_record.action_activate")
                        .tag(NextAction.activate)
                    Text("costumemaster.ai_record.action_costumes")
                        .tag(NextAction.switchCostume)
                    Text("costumemaster.ai_record.action_pick")
                        .tag(NextAction.pickupObject)
                    Text("costumemaster.ai_record.action_drop")
                        .tag(NextAction.drop)
                    Text("costumemaster.ai_record.action_nothing")
                        .tag(NextAction.nothing)
                }
                Spacer()
                Button {
                    journal.currentAction = action.rawValue
                }
                    label: {
                        Text("costumemaster.ai_record.perform_button")
                    }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }

    func entry(_ property: LocalizedStringKey, with answer: Bool) -> some View {
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
