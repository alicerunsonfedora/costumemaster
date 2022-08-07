//
//  AIPredeterminedTreeStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A strategist that will pick the best move based on a predetermined GKDecisionTree.
class AIPredeterminedTreeStrategist: AITreeStrategy {
    /// Initialize a predetermined tree strategist.
    override init() {
        super.init()
        recordsHistory = false
    }

    /// Returns the decision tree that the agent will use to determine its next best move.
    /// - Returns: A decision tree with hard-coded suggestions.
    override func makeDecisionTree() -> GKDecisionTree {
        let dtree = GKDecisionTree(attribute: "canEscape?".toProtocol())
        let root = dtree.rootNode

        let canEscape = root?.createBranch(value: true, attribute: "nearExit?".toProtocol())
        canEscape?.createBranch(value: true, attribute: "STOP".toProtocol())
        canEscape?.createBranch(value: false, attribute: "MOVE_EXIT_CLOSER".toProtocol())

        let cannotEscape = root?.createBranch(value: false, attribute: "nearInput?".toProtocol())
        let activeInput = cannotEscape?.createBranch(value: true, attribute: "inputActive?".toProtocol())
        let allActive = activeInput?.createBranch(value: true, attribute: "allInputsActive?".toProtocol())
        allActive?.createBranch(value: true, attribute: "MOVE_EXIT_CLOSER".toProtocol())
        allActive?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())

        let needsObj = activeInput?.createBranch(value: false, attribute: "requiresObject?".toProtocol())
        let hasObj = needsObj?.createBranch(value: true, attribute: "hasObject?".toProtocol())
        hasObj?.createBranch(value: true, attribute: "DROP".toProtocol())
        hasObj?.createBranch(value: false, attribute: "MOVE_OBJECT_CLOSER".toProtocol())

        let requiresCostume = needsObj?.createBranch(value: false, attribute: "requiresCostume?".toProtocol())
        let wearingCostume = requiresCostume?.createBranch(value: true, attribute: "wearingCostume?".toProtocol())
        wearingCostume?.createBranch(value: true, attribute: "ACTIVATE".toProtocol())
        wearingCostume?.createBranch(value: false, attribute: "NEXT_COSTUME".toProtocol())

        let inputImportant = requiresCostume?.createBranch(value: false, attribute: "inputRelevant?".toProtocol())
        inputImportant?.createBranch(value: true, attribute: "ACTIVATE".toProtocol())
        inputImportant?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())

        let nearObj = cannotEscape?.createBranch(value: false, attribute: "nearObj?".toProtocol())
        nearObj?.createBranch(value: true, attribute: "PICK_UP".toProtocol())
        nearObj?.createBranch(value: false, attribute: "MOVE_INPUT_CLOSER".toProtocol())

        return dtree
    }
}
