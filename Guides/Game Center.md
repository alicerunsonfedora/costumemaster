# Game Center

The Costumemaster includes integrations with Game Center, Apple's social network for games where players can earn achievements,
participate in leaderboards, and challenge others in a fun way. This document covers some important information about Game Center
integration.

## Achievements

As of The Costumemaster v1.0.0, there are a total of eight visible achievements:

- **Learning to Fly**: Become a bird for the first time.
- **It's About Perspective**: Break out of bounds and find the secret.
- **Overclocker**: Complete the level "Divergent" in 100 seconds or less.
- **Thinking with Magic**: Become a sorceress for the first time.
- **Costumemastery**: Complete an advanced level in 10 costume switches or less.
- **Cut and Paste**: Clone yourself for the first time.
- **Quickfooted**: Switch to the bird costume at least 100 times.
- **Underneath it All**: Find out who you really are.

There is a single hidden achievement that is accessible via an easter egg. These achievements can be referenced with the 
`GameAchievement` enumeration.

## Leaderboards

On applicable levels, there are daily recurring leaderboards available. When a player completes an advanced level with leaderboard
support, their scores will be submitted to Game Center automatically.

- Important: Submitting leaderboard scores to Game Center is only supported on macOS Big Sur (11.0) or higher. This is not supported on
macOS Mojave (10.14) or macOS Catalina (10.15).

## Accessing Game Center

The Game Center dashboard can be accessed on the main menu with the Game Center icon on devices running macOS Mojave or macOS
Catalina, or via the access point in macOS Big Sur and later.
