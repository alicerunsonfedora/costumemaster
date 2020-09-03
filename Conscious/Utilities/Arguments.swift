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

import Foundation

extension CommandLine {
    /// Parse the command line arguments to get the settings for this execution context.
    /// - Returns: A structure that contains the argument data.
    static func parse() -> CommandLineArguments {
        return CommandLineArguments(startLevel: CommandLine.getArgument(of: "--start-level"))
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
}
