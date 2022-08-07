//
//  Arguments.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/3/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Bunker
import Foundation

extension CommandLine {
    /// Parse the command line arguments to get the settings for this execution context.
    /// - Returns: A structure that contains the argument data.
    static func parse() -> CommandLineArguments {
        CommandLineArguments(
            startLevel: CommandLine.getArgument(of: "--start-level"),
            useAgentTesting: CommandLine.getArgument(of: "--agent-test-mode") == "true",
            agentTestingType: CommandLineArguments.AgentTestingType(
                rawValue: CommandLine.getArgument(of: "--agent-type") ?? "random"
            ) ?? CommandLineArguments.AgentTestingType.randomMove,
            agentMoveRate: Int(CommandLine.getArgument(of: "--agent-move-rate") ?? "")?.clamp(to: 1 ..< Int.max)
        )
    }

    /// Parse the command line arguments to get the settings for this execution context.
    /// - Parameter arguments: The list of arguments to parse.
    /// - Returns: A structure that contains the argument data.
    static func parse(_ arguments: [String]) -> CommandLineArguments {
        CommandLineArguments(
            startLevel: CommandLine.getArgument(of: "--start-level", from: arguments),
            useAgentTesting: CommandLine.getArgument(of: "--agent-test-mode", from: arguments) == "true",
            agentTestingType: CommandLineArguments.AgentTestingType(
                rawValue: CommandLine.getArgument(of: "--agent-type", from: arguments) ?? "random"
            ) ?? CommandLineArguments.AgentTestingType.randomMove,
            agentMoveRate: Int(
                CommandLine.getArgument(of: "--agent-move-rate", from: arguments) ?? ""
            )?.clamp(to: 1 ..< Int.max)
        )
    }

    /// Get the resulting value of a passed argument.
    /// - Parameter flag: The argument to get the value of.
    /// - Returns: The string value from the argument, or nil if it doesn't exit.
    static func getArgument(of flag: String) -> String? {
        if CommandLine.arguments.isEmpty { return nil }
        if let index = CommandLine.arguments.firstIndex(of: flag) {
            if (index + 1) >= CommandLine.arguments.count { return nil }
            return CommandLine.arguments[index + 1]
        }
        return nil
    }

    /// Get the resulting value of a passed argument.
    /// - Parameter flag: The argument to get the value of.
    /// - Parameter args: The list of arguments to retrieve values from.
    /// - Returns: The string value from the argument, or nil if it doesn't exit.
    static func getArgument(of flag: String, from args: [String]) -> String? {
        if args.isEmpty { return nil }
        if let index = args.firstIndex(of: flag) {
            if (index + 1) >= args.count { return nil }
            return args[index + 1]
        }
        return nil
    }
}
