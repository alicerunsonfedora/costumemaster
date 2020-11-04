//
//  CommandLineArguments.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/3/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure that contains the command line arguments for the execution context.
struct CommandLineArguments {

    /// The name of the file to open on startup. Defaults to nil (no file).
    public let startLevel: String?

    /// Whether to enable AI mode. Defaults to false.
    public let useAgentTesting: Bool

    /// The type of agent to use in AI mode.
    public let agentTestingType: AgentTestingType

    /// The maximum number of moves the agent can make at a time.
    public let agentMoveRate: Int?

    /// An enumeration that represents the AI mode types.
    enum AgentTestingType: String, CaseIterable {

        /// A randomly-moving agent.
        case randomMove = "random"

        /// A randomly-moving agent, picking a random action with the highest value.
        case randomWeightMove = "randomWeighted"

        /// A reflex agent.
        case reflex = "reflex"

        /// An agent with a pre-determined decision tree.
        case predeterminedTree = "predTree"

//        /// An agent with a dynamically generated decision tree based on its previous actions.
//        case historyTree = "historyTree"
    }
}
