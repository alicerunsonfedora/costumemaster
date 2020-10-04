//
//  CGSize.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension CGSize {

    /// - Parameter squareOf: The square's width/height.
    init(squareOf: Float) {
        self.init()
        self.width = CGFloat(squareOf)
        self.height = CGFloat(squareOf)
    }

}
