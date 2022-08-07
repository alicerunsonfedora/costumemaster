//
//  AISimulatorAgentImage.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A view that constructs an agent image.
struct AISimulatorAgentImage: View {
    /// The agent type that will be used for the image.
    var agent: CommandLineArguments.AgentTestingType

    /// Returns the name of the symbol to use.
    func symbol() -> String {
        switch agent {
        case .randomMove:
            return "die.face.5"
        case .randomWeightMove:
            return "scalemass"
        case .reflex:
            return "figure.walk"
        case .predeterminedTree:
            return "arrow.triangle.branch"
        case .tealConverse:
            return "studentdesk"
        default:
            return "questionmark"
        }
    }

    /// Returns the image view that hosts the symbol.
    func image() -> some View {
        Image(systemName: symbol())
    }

    /// Returns the background for the image view.
    func background() -> some View {
        switch agent {
        case .randomMove, .randomWeightMove, .reflex:
            return LinearGradient(
                gradient: Gradient(colors: [.red, .orange]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .predeterminedTree:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .tealConverse:
            return LinearGradient(
                gradient: Gradient(colors: [
                    .init(red: 0.3, green: 1, blue: 0.8),
                    .init(red: 0.1, green: 0.5, blue: 0.7),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [.gray, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    /// The main body of the view.
    var body: some View {
        self.image()
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.background())
    }
}

/// A preview container of the images.
struct AISimulatorAgentImage_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AISimulatorAgentImage(agent: .randomMove)
                .frame(width: 76, height: 76)
            AISimulatorAgentImage(agent: .reflex)
                .frame(width: 76, height: 76)
            AISimulatorAgentImage(agent: .predeterminedTree)
                .frame(width: 76, height: 76)
            AISimulatorAgentImage(agent: .tealConverse)
                .frame(width: 76, height: 76)
        }
    }
}
