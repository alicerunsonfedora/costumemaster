//
//  PropertyLists.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/28/20.
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
