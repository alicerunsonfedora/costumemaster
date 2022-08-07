//
//  Tooltip.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/2/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftUI

/// A view that displays a tooltip.
/// Credit goes to onmyway133: https://onmyway133.github.io/blog/How-to-make-tooltip-in-SwiftUI-for-macOS/
@available(macOS, introduced: 10.15, deprecated: 11.0, message: "Use the .help modifier instead.")
struct Tooltip: NSViewRepresentable {

    /// The tooltip message to display.
    let tooltip: String

    /// Create the view.
    func makeNSView(context: NSViewRepresentableContext<Tooltip>) -> NSView {
        let view = NSView()
        view.toolTip = tooltip
        return view
    }

    /// Update the view.
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Tooltip>) {
        nsView.toolTip = tooltip
    }
}
