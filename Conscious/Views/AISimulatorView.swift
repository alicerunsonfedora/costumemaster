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

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A view that allows player to customize AI simulation features
@available(OSX 10.15, *)
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
                return zone["Description"] as? String ?? "No description provided."
            }
        }
        return "Select an agent to get its description."
    }

    /// The main body of the view.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image("dpad.fill")
                    .font(.largeTitle)
                Text("Run an AI simulation")
                    .font(.largeTitle)
                    .bold()
            }

            Text(
                "Watch artificial intelligence agents attempt to play levels and solve puzzles!"
                + " The simulator will create the level you choose and prepare the agent so that"
                + " it can begin making moves and attempt to solve the puzzle."
            )

            Divider()

            HStack(alignment: .top, spacing: 8) {
                Image(agentType.rawValue)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 76, maxHeight: 76)
                    .cornerRadius(12.0)
                VStack(alignment: .leading) {
                    Text(self.getName(of: agentType))
                        .font(.title)
                        .bold()
                    Text(self.getAgentDescription())
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxHeight: .infinity)

            Picker("Run simulation with agent:", selection: $agentType) {
                ForEach(CommandLineArguments.AgentTestingType.allCases, id: \.self) { type in
                    Text(self.getName(of: type)).tag(type)
                }
            }

            Divider()

            Picker("Run simulation in level: ", selection: $simulationLevel) {
                ForEach(AgentLevels.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Limit move generation per batch to: ")
                    Spacer()
                    Stepper(value: $agentBudget, in: 1...Int.max, step: 1) {
                        Text("\(agentBudget) move\(agentBudget > 1 ? "s": "")")
                    }
                }

                if self.agentBudget > 250 {
                    HStack {
                        Image("exclamationmark.triangle")
                            .foregroundColor(.secondary)
                            .font(.body)
                        Text("Increasing the budget rate may cause performance issues with the simulation.")
                            .foregroundColor(.secondary)
                    }
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
                NSWorkspace.shared.open(
                    URL(
                        string: "https://costumemaster.marquiskurt.net/working-with-agents.html"
                    )!
                )
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
                Text("Start Simulation")
            }
        }
    }
}

/// A preview container for the simulator view.
@available(OSX 10.15, *)
struct AISimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorView { (_, _, _) in }
            .frame(width: 400, height: 450)
    }
}
