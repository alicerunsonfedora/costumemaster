//
//  SwitchRequisite.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/27/20.
//

import Foundation

/// A data structure that represents a configuration for a switch requisite.
///
/// This structure is used to describe what inputs will trigger an output, and how many inputs are needed to
/// activate the switch.
struct SwitchRequisite {

    /// The location in the map that corresponds to the output.
    var outputLocation: CGPoint

    /// A list of locations that correspond to the inputs.
    var requiredInputs: [CGPoint]

    /// The requisite for the output to be activated.
    var requisite: GameSignalMethod?

    /// Get the requisite for a given output based on a configuration string.
    /// - Parameter string: The string to read and convert into a requisite.
    /// - Returns: The input requisite, or a null type if no requisites match.
    static func getRequisite(from string: String) -> GameSignalMethod? {
        switch string {
        case "AND":
            return .allInputs
        case "OR":
            return .anyInput
        default:
            return nil
        }
    }
}
