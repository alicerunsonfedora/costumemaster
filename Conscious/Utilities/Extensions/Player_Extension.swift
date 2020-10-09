//
//  Player_Extension.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/9/20.
//

import Foundation
import SpriteKit

extension Player {
    /// Move the player in a given direction, relative to the size of the world.
    ///
    /// This method is typically preferred since AI agents can call this method instead of calculating the delta
    /// beforehand. This method also handles any animations that need to be added to make sure the player
    /// has an appropriate animation while walking.
    ///
    /// - Parameter direction: The direction the player will move in.
    /// - Parameter unit: The base unit to calculate the movement delta, relatively.
    public func move(_ direction: PlayerMoveDirection, unit: CGSize) {
        // Stop if we're changing costumes.
        if self.animating && self.isChangingCostumes { return }

        // If we're trying to move and we aren't animating anymore, change the costume change flag.
        // This usually occurs when the player tries to move during a costume change and gets
        // softlocked.
        if !self.animating && self.isChangingCostumes { self.isChangingCostumes = false }

        // Create the delta vector and animation
        var delta = CGVector(dx: 0, dy: 0)
        var action: SKAction?

        // Calculate the correct delta based on the direction and generate the proper animation.
        switch direction {
        case .north:
            delta.dy += unit.height / 2
            action = SKAction.animate(
                with: self.backwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .south:
            delta.dy -= unit.height / 2
            action = SKAction.animate(
                with: self.forwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .east:
            delta.dx += unit.width / 2
            action = SKAction.animate(
                with: self.sidewardWalkCycle,
                timePerFrame: 0.25,
                resize: false,
                restore: true
            )
        case .west:
            delta.dx -= unit.width / 2
            action = SKAction.animate(
                with: self.sidewardWalkCycle,
                timePerFrame: 0.25,
                resize: false,
                restore: true
            )
        }

        // Call the move method with the new delta.
        self.move(delta)

        // If we found an animation, play it and set animating to true.
        if action != nil && !self.animating {
            self.run(SKAction.repeatForever(action!))
            if direction == .west {
                self.xScale *= -1
                self.hud.xScale *= -1
            }
            self.animating = true
        }
    }
}
