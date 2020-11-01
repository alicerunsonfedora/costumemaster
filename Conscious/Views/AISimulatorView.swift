//
//  AISimulatorView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/1/20.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, *)
struct AISimulatorView: View {

    @State var agentType: CommandLineArguments.AgentTestingType = .randomMove
    @State var simulationLevel: AgentLevels = .entry
    @State var agentBudget: Int = 500
    @State var onStartSimulation: (CommandLineArguments.AgentTestingType, AgentLevels, Int) -> Void

    enum AgentLevels: String, CaseIterable {
        case entry = "Entry"
    }

    func getName(of agent: CommandLineArguments.AgentTestingType) -> String {
        if let dict = plist(from: "AgentTypes") {
            if let zone = dict[agent.rawValue] as? NSMutableDictionary {
                return zone["Title"] as? String ?? "MISSINGNO"
            }
        }
        return "MISSINGNO"
    }

    func getAgentDescription() -> String {
        if let dict = plist(from: "AgentTypes") {
            if let zone = dict[agentType.rawValue] as? NSMutableDictionary {
                return zone["Description"] as? String ?? "No description provided."
            }
        }
        return "Select an agent to get its description."
    }

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

@available(OSX 10.15, *)
struct AISimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        AISimulatorView() { (_, _, _) in }
            .frame(width: 400, height: 450)
    }
}
