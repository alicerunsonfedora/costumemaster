//
//  PropertyLists.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/28/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Read a property list file and get the contents as a dictionary.
/// - Parameter plistName: The name of the property lsit file to get the data of.
/// - Returns: A dictionary representation of the file, or a null value if none is found.
func plist(from plistName: String) -> NSDictionary? {
    var plistData: NSDictionary?
    if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
        plistData = NSDictionary(contentsOfFile: path)
    }
    return plistData
}

/// Returns the level properties file as a list of level items.
///
/// - Returns: A list of level items, or nil if an unexpected error occurs.
func getLevelProperties() -> [GameLevelItem]? {
    guard let dataURL = Bundle.main.url(forResource: "LevelProperties", withExtension: "plist") else {
        return nil
    }
    do {
        return try PropertyListDecoder().decode([GameLevelItem].self, from: Data(contentsOf: dataURL))
    } catch {
        print("An unknown error occurred: \(error)")
        return nil
    }
}
