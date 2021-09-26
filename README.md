<div>
<h1>
<img src="https://github.com/alicerunsonfedora/CS400/raw/root/logomark.svg" alt="The Costumemaster"/>
</h1>
</div>

[![License][img-license]][license] ![Version][img-version] ![Swift 5][img-swift] [![Documentation][img-docs]][docs]

An acclaimed costume designer and software engineer wakes up from a blackout to an eerily familiar scene. But, something
isn't quite... right.... Traverse through a dream-like, constantly changing bedroom and office and get out as quickly as
you can. Can you make it out and figure out what's going on?

<div>
<a href="https://apps.apple.com/us/app/the-costumemaster/id1529632296">
<img height="54" src="https://github.com/alicerunsonfedora/CS400/raw/root/.readme/macappstore.svg" alt="Get it on the Mac App Store"/>
</a>
<a href="https://www.producthunt.com/posts/the-costumemaster?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-the-costumemaster" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=270923&theme=light" alt="The Costumemaster - A puzzle game where you switch costumes and escape | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>
</div>

## Try _The Costumemaster: Reloaded_

_The Costumemaster: Reloaded_ is a completely redesigned version of _The Costumemaster_ with support for controllers,
new features and improvements, and compatibility with Windows and Linux. You can get _The Costumemaster: Reloaded_ today
from the Mac App Store or from [itch.io](https://marquiskurt.itch.io/costumemaster-reloaded) today.

<div>
<a href="https://apps.apple.com/us/app/the-costumemaster-reloaded/id1573181569">
<img height="54" src="https://github.com/alicerunsonfedora/CS400/raw/root/.readme/macappstore.svg" alt="Get it on the Mac App Store"/>
</a>
</div>


## Features

![Feature Set](https://github.com/alicerunsonfedora/CS400/raw/root/.readme/featureset.png)

## Objective

The primary objective of this project is to take the concepts from _CS440: Principles of Artificial Intelligence_ and
build a better understanding of agents and apply these concepts by implementing and comparing agents in a video game.

More information on the objective of this repository can be found in the [design proposal][proposal].

### Project Roadmap

| Status | Due Date | Milestone |
| ------ | ----------- | ----------- |
| 🟢 | September 21, 2020 | Working Game |
| ❎ | October 19, 2020 | Adding Apple's agents with GameplayKit\* |
| ✳️ | November 9, 2020 | Adding custom agents and beating Apple<sup>✝</sup> |
| 🟢 | November 16, 2020 | Final presentation and cleanup |

Details on these milestones can be found on the [Milestones page on GitHub][milestones].

Documentation on how to work with agents [can be found on the documentation pages][ai].

<small>*Due to the nature of the strategists with GameplayKit's AIs, it is impossible to complete this milestone.
Currently, the goal is to supply custom agents that attempt to solve the world.</small>

<small><sup>✝</sup>Due to limitations with the second milestone, beating Apple is not really possible.</small>

## Build instructions

### Requirements

- Xcode 12.2\* or higher
- macOS 11.0 (Big Sur) or higher
- [KeyboardShortcuts][keys] (added when cloning)
- [GBMKUtils][utils] (added when cloning)
- (Optional, but recommended) [SwiftLint][linter]

1. Clone the Xcode project and ensure that dependencies are install with the Swift Package Manager.
2. In the project settings, change the bundle identifier to your own bundle identifier (See Game Center, In-App
    Purchases).
3. Run the **Game** scheme to build the project in Xcode.

To make a release version, click on the destination ("My Mac") and select "Any Mac (Apple Silicon, Intel)", then go to
**Product &rsaquo; Archive**.

### Game Center

The Costumemaster integrates with Game Center to allow players to earn achievements, challenge others, and rank in the
leaderboards for the best scores on levels (scoring system similar to what AI agents use). Game Center is a service that
requires an Apple Developer account and an app registered in App Store Connect with the bundle identifier of the game.
To test Game Center achievements, make sure that you update the build identifier in the project to the app's identifier
in App Store Connect and make sure that the achievements with the IDs listed in [GameAchievements.swift][gcachieve] in
the Achievements list of the Game Center section.

![Game Center](https://github.com/alicerunsonfedora/CS400/raw/root/.readme/gamecenter.png)

To access features like the new access point and leaderboard submission, ensure that Xcode includes at least the macOS
11.0 SDK.

### In-App Purchases

The Costumemaster also integrates with StoreKit to provide in-app purchase support for DLC content such as "Watch Your
Step!". In-app purchases require an Apple Developer account with an app registered in App Store Connect with the bundle
identifier of the game. In-app purchases will need to be configured with the IDs listed in 
[IAPManager.PurchaseableContent][iapcontent] in App Store Connect.

### About SwiftLint

This project includes support for SwiftLint, a utility that enforces recommended Swift styling practices. While it is
not required to install SwiftLint to build the project, it is highly recommended. The project, during build, will do the
following with SwiftLint:

- Resolve any quick, auto-correctable fixes with `swiftlint autocorrect`.
- Run the linter on all source files and present warnings/errors in Xcode after running.

The following practices are also being implemented with SwiftLint:

- Lines should be no longer than 120 characters long, similar to PEP8 standards with Python.
- Function body length will be ignored.
- Bodies for types should not exceed 400 lines (warnings issued at 250 lines).
- Files should not exceed 1000 lines (warnings issued at 500 lines).
- When possible, avoid making a filtered list and iterating over it; use the `for x in x where y` format instead.

### Documentation

Documentation is handled by [Jazzy][jazzy], a documentation generator provided by Realm. Follow the instructions to
build the documentation:

1. Run `bundle install` to install the dependencies needed. In some cases, you may need to set parameters for installing
    sqlite3 or for installing the Xcode Command Line Tools.
2. Run `docs_build.sh` to build the docs.

---

(C) 2020 Marquis Kurt. All rights reserved. Game Center, the Game Center logo, SF Symbols, and macOS are registered
trademarks of Apple Inc.

> For olders versions of The Costumemaster (v1.x-v2.0.0), music is written by Kai Engel.

<!-- Links in page -->
[milestones]: https://github.com/alicerunsonfedora/CS400/milestones?direction=asc&sort=due_date&state=open
[linter]: https://realm.github.io/SwiftLint/
[utils]: https://github.com/alicerunsonfedora/GBMKUtils
[keys]: https://github.com/sindresorhus/KeyboardShortcuts
[gcachieve]: ./Conscious/Enums/GameAchievments.swift
[iapcontent]: ./Conscious/Classes/App/Purchases/IAPManager.swift
[jazzy]: https://github.com/realm/jazzy
[proposal]: ./Guides/Project%20Proposal.md
[license]: LICENSE.txt
[docs]: https://costumemaster.marquiskurt.net
[ai]: https://costumemaster.marquiskurt.net/working-with-agents.html

<!-- Image links -->
[img-license]: https://img.shields.io/github/license/alicerunsonfedora/CS400
[img-version]: https://img.shields.io/github/v/release/alicerunsonfedora/CS400
[img-docs]: https://costumemaster.marquiskurt.net/badge.svg
[img-swift]: https://img.shields.io/badge/swift-5.3-orange.svg
