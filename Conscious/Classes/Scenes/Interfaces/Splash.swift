//
//  Splash.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// The scene that corresponds to the splash screen.
class SplashScene: SKScene {
    /// The label node that contains the by text.
    var byText: SKLabelNode?

    /// The sprite node that corresponds to the logomark.
    var logomark: SKSpriteNode?

    /// Load the splashscreen then fade into the main menu.
    override func sceneDidLoad() {
        scaleMode = .aspectFill

        guard let byText = childNode(withName: "byText") as? SKLabelNode else {
            return
        }
        guard let logomark = childNode(withName: "logo") as? SKSpriteNode else {
            return
        }

        self.byText = byText
        self.logomark = logomark

        self.byText?.alpha = 0
        self.logomark?.alpha = 0

        self.byText?.text = NSLocalizedString("costumemaster.ui.splash_by", comment: "Created by")

        let actions: [SKAction] = [
            SKAction.run {
                self.byText?.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
            },
            SKAction.run {
                self.logomark?.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
            },
            SKAction.wait(forDuration: 3.0),
            SKAction.run {
                self.launchMain()
            },
        ]

        run(SKAction.sequence(actions))
    }

    /// Launch the main menu.
    func launchMain() {
        guard let mainMenu = SKScene(fileNamed: "MainMenu") as? MainMenuScene else {
            NSApplication.shared.terminate(nil)
            return
        }

        view?.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 1.5))
    }
}
