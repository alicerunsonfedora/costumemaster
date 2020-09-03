//
//  CommandLineArguments.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/3/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A data structure that contains the command line arguments for the execution context.
struct CommandLineArguments {

    /// The name of the file to open on startup. Defaults to nil (no file).
    public let startLevel: String?
}
