//
//  LevelDataConfiguration.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure used to determine the properties of a level based on a user data dictionary.
public struct LevelDataConfiguration {
    /// The ID that determines what costumes are avaiable, with 0 indicating no costumes annd 3 indicating all costumes.
    public let costumeID: Int

    /// The name of the SKScene that will load after the current scene this level configuration is attached to.
    public let linksToNextScene: String

    /// The costume the player will start with by default.
    public let startWithCostume: PlayerCostumeType

    /// The matrix location of the exit door.
    public let exitLocation: CGPoint

    /// The default amount of time on alarm clock timers.
    public let defaultTimerDelay: Double

    /// A list of the requisites for switches and receivers.
    let requisites: [SwitchRequisite]

    /// A default level configuration with no costumes loaded and the next scene set to the main menu.
    static var `default`: LevelDataConfiguration {
        return LevelDataConfiguration(
            costumeID: 0,
            nextScene: "MainMenu",
            startingWith: .default,
            under: [],
            with: CGPoint(x: 0, y: 0),
            timed: 3.0
        )
    }

    /// Initialize a level configuration.
    /// - Parameter costumeID: The costume ID that determines what costumes are available.
    /// - Parameter nextScene: The SKScene name that will load after the scene attached to this configuration.
    /// - Parameter costume: The type of costume the player starts with.
    /// - Parameter requisites: The requisites list for all inputs and and outputs.
    /// - Parameter exit: The matrix location of the exit.
    init(
        costumeID: Int,
        nextScene: String,
        startingWith costume: PlayerCostumeType,
        under requisites: [SwitchRequisite],
        with exit: CGPoint,
        timed delay: Double
    ) {
        self.costumeID = costumeID
        self.linksToNextScene = nextScene
        self.startWithCostume = costume
        self.requisites = requisites
        self.exitLocation = exit
        self.defaultTimerDelay = delay
    }

    /// Initialize a level configuration.
    /// - Parameter userData: The user data dictionary to read data from and generate a configuration.
    public init(from userData: NSMutableDictionary) {
        self.costumeID = userData["availableCostumes"] as? Int ?? 0
        self.linksToNextScene = userData["levelLink"] as? String ?? "MainMenu"
        self.startWithCostume = PlayerCostumeType(
            rawValue: userData["startingCostume"] as? String ?? "Default"
        ) ?? .default
        self.defaultTimerDelay = Double(userData["timer"] as? Int ?? 3)
        self.requisites = LevelDataConfiguration.parseRequisites(from: userData)
        var exit = CGPoint(x: 0, y: 0)
        if let exitData = userData["exitAt"] as? String {
            let exitCoords = exitData.split(separator: ",")
            if !exitCoords.isEmpty {
                exit = CGPoint(x: Int(exitCoords.first!) ?? -1, y: Int(exitCoords.last!) ?? -1)
            }
        }
        self.exitLocation = exit
    }

    /// Parse a given dictionary into a list of requisites.
    ///
    /// This method will read a dictionary, filter for fields with the format `"requisite_COL_ROW"`, and proceed to
    /// parse t he resulting value as data about how the output is defined.
    ///
    /// The format for a requisite string is `"METHOD;COL,ROW;"`, where `METHOD` can be `AND` or `OR`, and every
    /// predicate afterwards is the coordinate to a corresponding input. For example: setting the key `requisite_1_1`
    /// to `AND;2,1;3,1;` will tell the scene to connect the output at (1, 1) to the inputs (2, 1) and (3, 1) while also
    /// making the connect an `AND` connection where both inputs must be active to activate the output.
    ///
    /// - Parameter dictionary: The dictionary to read from.
    /// - Returns: A list of requisites for switches and outputs.
    static func parseRequisites(from dictionary: NSMutableDictionary) -> [SwitchRequisite] {
        var requisites: [SwitchRequisite] = []

        for key in dictionary.keyEnumerator() {
            if var dataKey = key as? String {
                if !dataKey.starts(with: "requisite_") { continue }
                dataKey = dataKey.replacingOccurrences(of: "requisite_", with: "")
                let requisiteCoordinates = dataKey.split(separator: "_")
                if requisiteCoordinates.first == nil { continue }

                let outputLocation = CGPoint(
                    x: Int(requisiteCoordinates.first!) ?? -1,
                    y: Int(requisiteCoordinates.last!) ?? -1
                )
                var type: GameSignalMethod?
                var inputLocations: [CGPoint] = []

                if let valueData = dictionary.value(forKey: "requisite_" + dataKey) as? String {
                    var parsed = valueData.split(separator: ";")
                    if parsed.isEmpty { continue }

                    type = SwitchRequisite.getRequisite(from: String(parsed.removeFirst()))
                    for input in parsed {
                        let coords = input.split(separator: ",")
                        if coords.count != 2 { continue }
                        inputLocations.append(
                            CGPoint(
                                x: Int(coords.first!) ?? -1,
                                y: Int(coords.last!) ?? -1
                            )
                        )
                    }
                }

                requisites.append(
                    SwitchRequisite(outputLocation: outputLocation, requiredInputs: inputLocations, requisite: type)
                )
            }
        }
        return requisites
    }
}
