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
///
/// The user data dictionary requires the following fields:
/// - `exitAt` field: (String) determines column and row coordinates to the exit node.
/// - `availableCostumes` field: (Int) determines which costumes are available.
/// - `levelLink` field: (String) determines the next scene to display after this scene ends.
/// - `startingCostume` field: (String) determines which costume the player starts with.
/// - `requisite_COL_ROW` field(s): (String) determines what outputs require certain inputs.
///
/// These fields are not required but can be added to extend the configuration:
/// - `achievementTrigger` field: (String) determines the achievement to trigger when passing
/// through an achievement trigger.
/// - `timer` field: (Int) determines how long a timer in the level will last. Defaults to 3 seconds.
/// - `disallowCostume` field: (String) determines which costume cannot be used in this level.
/// - `trackName` field: (String) determines what music track to play.
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

    /// The achievement to earn when passing through the achievement trigger, if one exists.
    let achievementTrigger: GameAchievement?

    /// A costume to remove from the queue.
    let disallowCostume: PlayerCostumeType?

    /// The track name to play as music.
    let trackName: String?

    /// A default level configuration with no costumes loaded and the next scene set to the main menu.
    static var `default`: LevelDataConfiguration {
        LevelDataConfiguration(
            costumeID: 0,
            nextScene: "MainMenu",
            startingWith: .default,
            disallowing: nil,
            under: [],
            with: CGPoint(x: 0, y: 0),
            timed: 3.0,
            earning: nil,
            playing: nil
        )
    }

    /// Initialize a level configuration.
    /// - Parameter costumeID: The costume ID that determines what costumes are available.
    /// - Parameter nextScene: The SKScene name that will load after the scene attached to this configuration.
    /// - Parameter costume: The type of costume the player starts with.
    /// - Parameter requisites: The requisites list for all inputs and and outputs.
    /// - Parameter exit: The matrix location of the exit.
    /// - Parameter delay: The default number of seconds for a timer to be active for.
    /// - Parameter achievement: The game achievement to earn when passing through an achievement trigger.
    init(
        costumeID: Int,
        nextScene: String,
        startingWith costume: PlayerCostumeType,
        disallowing disallowedCostume: PlayerCostumeType?,
        under requisites: [SwitchRequisite],
        with exit: CGPoint,
        timed delay: Double,
        earning achievement: GameAchievement?,
        playing music: String?
    ) {
        self.costumeID = costumeID
        linksToNextScene = nextScene
        startWithCostume = costume
        self.requisites = requisites
        exitLocation = exit
        defaultTimerDelay = delay
        achievementTrigger = achievement
        disallowCostume = disallowedCostume
        trackName = music
    }

    /// Initialize a level configuration.
    /// - Parameter userData: The user data dictionary to read data from and generate a configuration.
    public init(from userData: NSMutableDictionary) {
        costumeID = userData["availableCostumes"] as? Int ?? 0
        linksToNextScene = userData["levelLink"] as? String ?? "MainMenu"
        startWithCostume = PlayerCostumeType(
            rawValue: userData["startingCostume"] as? String ?? "Default"
        ) ?? .default
        defaultTimerDelay = Double(userData["timer"] as? Int ?? 3)
        requisites = LevelDataConfiguration.parseRequisites(from: userData)
        var exit = CGPoint(x: 0, y: 0)
        if let exitData = userData["exitAt"] as? String {
            let exitCoords = exitData.split(separator: ",")
            if !exitCoords.isEmpty {
                exit = CGPoint(x: Int(exitCoords.first!) ?? -1, y: Int(exitCoords.last!) ?? -1)
            }
        }
        exitLocation = exit
        achievementTrigger = GameAchievement(rawValue: userData["achievementTrigger"] as? String ?? "null")
        trackName = userData["trackName"] as? String

        guard let disallowed = userData["disallowCostume"] as? String else {
            disallowCostume = nil
            return
        }
        disallowCostume = PlayerCostumeType(rawValue: disallowed)
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
