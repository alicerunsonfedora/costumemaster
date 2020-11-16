//
//  ToolbarButtonStyle.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {

    func makeBody(configuration: ToolbarButtonStyle.Configuration) -> some View {
        Group {
            if #available(OSX 11.0, *) {
                configuration.label
                    .font(.title2)
                    .padding(8)
                    .background(configuration.isPressed
                                    ? Color(.controlHighlightColor)
                                    : Color.clear
                    )
                    .compositingGroup()
                    .cornerRadius(6.0)
                    .frame(maxWidth: 48, maxHeight: 48)
            } else {
                configuration.label
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(configuration.isPressed ? Color(.controlAccentColor) : Color(.controlColor))
                    .shadow(color: Color(.controlShadowColor), radius: 10, x: 0.0, y: 0.0)
                    .cornerRadius(3.0)
            }
        }
    }
}
