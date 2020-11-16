//
//  StateRecorderViewModel.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import Foundation
import CodableCSV

/// An observable class that handles state recording for machine learning.
class StateRecorderViewModel: ObservableObject {

    /// The list of entries to include.
    @Published var entries: [AIStateRecordable] = []

    /// The current assessment the model is viewing.
    @Published var currentAssessment: AIAbstractGameState.Assessement

    /// The current action as a result of this assessment.
    ///
    /// When this value is changed, `onReceiveAction` will be executed with the current assessment
    /// and action. This assessment-action pair will automatically be added to the entries list.
    @Published var currentAction: String = "" {
        didSet {
            self.onReceiveAction(currentAssessment, currentAction)
            self.addEntry(from: currentAssessment, with: currentAction)
        }
    }

    /// A closure that executes when the current action is changed.
    var onReceiveAction: (AIAbstractGameState.Assessement, String) -> Void

    /// Instantiate the assessment model.
    /// - Parameter assessment: The starting assessment to work with.
    public init(
        from assessment: AIAbstractGameState.Assessement,
        onReceiveAction: @escaping (AIAbstractGameState.Assessement, String) -> Void
    ) {
        self.currentAssessment = assessment
        self.onReceiveAction = onReceiveAction
    }

    /// Add an entry to the list of entries.
    /// - Parameter entry: The entry to include in the new
    func add(_ entry: AIStateRecordable) {
        self.entries.append(entry)
    }

    /// Add an assessment and action to the list of entries as a new entry.
    func addEntry(from assessment: AIAbstractGameState.Assessement, with action: String) {
        self.entries.append(AIStateRecordable(from: assessment, with: action))
    }

    func export(to csvPath: URL) {
        let encoder = CSVEncoder {
            $0.headers = AIStateRecordable.csvHeaders
            $0.encoding = .utf8
            $0.delimiters.row = "\n"
        }
        do {
            try encoder.encode(entries, into: csvPath)
        } catch {
            print("Failed to record states to URL \(csvPath.absoluteString)")
        }
    }

}
