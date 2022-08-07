//
//  AIStateRecordable.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure that represents a recorded state assessment and its resulting action.
///
/// This is typically used to construct a state recording to be fed into a machine learning
/// model for the Teal Converse agent.
struct AIStateRecordable: Codable {
    /// The CSV file headers for this structure.
    static let csvHeaders = [
        "canEscape",
        "nearExit",
        "nearInput",
        "inputActive",
        "inputRelevant",
        "requiresObject",
        "requiresCostume",
        "wearingCostume",
        "hasObject",
        "nearObject",
        "allInputsActive",
        "action",
    ]

    /// Can the agent escape?
    let canEscape: Bool

    /// Is the agent near the exit?
    let nearExit: Bool

    /// Is the agent near an input device?
    let nearInput: Bool

    /// Is the closest input nearby active?
    let inputActive: Bool

    /// Is the closest input device relevant to opening the exit?
    let inputRelevant: Bool

    /// Does the closest input require a heavy object?
    let requiresObject: Bool

    /// Does the closest input require a specific costume?
    let requiresCostume: Bool

    /// Is the agent wearing the right costume?
    let wearingCostume: Bool

    /// Does the agent have an object in its inventory?
    let hasObject: Bool

    /// Is the agent near an object?
    let nearObject: Bool

    /// Are all of the inputs that send signals to the exit door active?
    let allInputsActive: Bool

    /// The action that will be performed from this assessement.
    let action: String

    /// Construct a recordable state.
    /// - Parameter assessment: The assessment to use
    /// - Parameter result: The resulting action from the assessment
    init(from assessment: AIAbstractGameState.Assessement, with result: String) {
        allInputsActive = assessment.allInputsActive
        canEscape = assessment.canEscape
        hasObject = assessment.hasObject
        inputActive = assessment.inputActive
        inputRelevant = assessment.inputRelevant
        nearExit = assessment.nearExit
        nearInput = assessment.nearInput
        nearObject = assessment.nearObject
        requiresCostume = assessment.requiresCostume
        requiresObject = assessment.requiresObject
        wearingCostume = assessment.wearingCostume
        action = result
    }
}
