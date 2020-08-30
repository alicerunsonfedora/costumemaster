//
//  GameAchievments.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/30/20.
//

import Foundation

/// A enumeration that represents the different achievements players can earn in the game.
public enum GameAchievement: String {
    /// Face Reveal: Skipped the game and convinced her to do a face reveal.
    /// - **ID**: costumemaster.face_reveal
    case faceReveal = "costumemaster.face_reveal"

    /// Learning to Fly: Became a bird for the first time.
    /// - **ID**: costumemaster.new_bird
    case newBird = "costumemaster.new_bird"

    /// Thinking with Magic: Became a sorceress for the first time.
    /// - **ID**: costumemaster.new_sorceress
    case newSorceress = "costumemaster.new_sorceress"

    /// Underneath it All: Found out who you are.
    /// - **ID**: costumemaster.end_reveal
    case endReveal = "costumemaster.end_reveal"
}
