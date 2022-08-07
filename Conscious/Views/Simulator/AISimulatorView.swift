//
//  AISimulatorView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/1/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A view that allows player to customize AI simulation features
struct AISimulatorView: View {

    /// The type of agent to run in the simulation.
    @State var agentType: CommandLineArguments.AgentTestingType = .randomMove

    /// The level to run the simulation on.
    @State var simulationLevel: AgentLevels = .entry

    /// The agent's budget.
    @State var agentBudget: Int = 1

    /// A closure that executes when the player clicks "Start Simulation".
    @State var onStartSimulation: (CommandLineArguments.AgentTestingType, AgentLevels, Int) -> Void

    /// An enumeration that represents the levels agents can play.
    enum AgentLevels: String, CaseIterable {
        /// Basic.
        /// A level with a single lever and exit door.
        case basic = "Basic"

        /// Multi-input Basic.
        /// A level with a two levers and exit door.
        case multiBasic = "MultiInputBasic"

        /// Entry.
        case entry = "Entry"
    }

    /// Returns the title for the agent type.
    func getName(of agent: CommandLineArguments.AgentTestingType) -> String {
        if let dict = plist(from: "AgentTypes") {
            if let zone = dict[agent.rawValue] as? NSMutableDictionary {
                return zone["Title"] as? String ?? "MISSINGNO"
            }
        }
        return "MISSINGNO"
    }

    /// Returns the description for the agent type.
    func getAgentDescription() -> String {
        if let dict = plist(from: "AgentTypes") {
            if let zone = dict[agentType.rawValue] as? NSMutableDictionary {
                return zone["Description"] as? String ?? NSLocalizedString(
                    "costumemaster.ai_sim.select_desc_missing",
                    comment: "Missing description"
                )
            }
        }
        return NSLocalizedString("costumemaster.ai_sim.select_desc_default", comment: "Default text")
    }

    /// The main body of the view.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("costumemaster.ai_sim.select_title", image: "dpad.fill")
                .font(
                    .system(.largeTitle, design: .rounded)
                    .bold()
                )
            Text("costumemaster.ai_sim.select_detail")

            Divider()

            HStack(alignment: .top) {
                AISimulatorAgentImage(agent: agentType)
                    .frame(width: 76, height: 76)
                    .cornerRadius(12.0)
                VStack(alignment: .leading) {
                    Text(self.getName(of: agentType))
                        .font(.system(.title, design: .rounded))
                        .bold()
                    Text(self.getAgentDescription())
                        .multilineTextAlignment(.leading)
                }
                .frame(minHeight: 76, alignment: Alignment.top)
            }

            Picker("costumemaster.ai_sim.select_agent_prompt", selection: $agentType) {
                ForEach(CommandLineArguments.AgentTestingType.allCases, id: \.self) { type in
                    Text(self.getName(of: type)).tag(type)
                }
            }

            Divider()

            Picker("costumemaster.ai_sim.select_level_prompt", selection: $simulationLevel) {
                ForEach(AgentLevels.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("costumemaster.ai_sim.select_limit_prompt")
                    Spacer()
                    Stepper(value: $agentBudget, in: 1...Int.max, step: 1) {
                        Text("\(agentBudget) move\(agentBudget > 1 ? "s": "")")
                    }
                }

                if self.agentBudget > 250 {
                    Label("costumemaster.ai_sim.select_exceed_warn", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.secondary)
                }

            }

            Spacer()

            self.buttonBar
        }
        .padding()
        .frame(minWidth: 400, minHeight: 450)
    }

    /// The bottom button bar of the view.
    var buttonBar: some View {
        HStack {
            Button {
                if let book = Bundle.main.object(forInfoDictionaryKey: "CFBundleHelpBookName") as? String {
                    NSHelpManager.shared.openHelpAnchor("AISimulation_PREF", inBook: book)
                } else {
                    NSWorkspace.shared.open(
                        URL(string: "https://costumemaster.marquiskurt.net/working-with-agents.html")!
                    )
                }
            } label: {
                Image("questionmark")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .font(.callout)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 28, height: 28)
            .background(Color(.controlColor))
            .cornerRadius(25)
            .shadow(radius: 1)

            Spacer()

            Button {
                self.onStartSimulation(self.agentType, self.simulationLevel, self.agentBudget)
            } label: {
                Text("costumemaster.ai_sim.select_start")
            }
        }
    }
}

/// A preview container for the simulator view.
struct AISimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorView { (_, _, _) in }
            .frame(width: 400, height: 450)
    }
}
