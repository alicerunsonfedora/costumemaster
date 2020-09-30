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

class SplashScene: SKScene {

    var byText: SKLabelNode?
    var logomark: SKSpriteNode?

    override func sceneDidLoad() {
        self.scaleMode = .aspectFill

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
            }
        ]

        self.run(SKAction.sequence(actions))
    }

    func launchMain() {
        guard let mainMenu = SKScene(fileNamed: "MainMenu") as? MainMenuScene else {
            NSApplication.shared.terminate(nil)
            return
        }

        self.view?.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 1.5))
    }

}
