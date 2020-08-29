//
//  MainMenu.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/26/20.
//

import Foundation
import SpriteKit
import GameKit

/// The scene class for the main menu.
class MainMenuScene: SKScene, GKGameCenterControllerDelegate {

    /// The label node for the word "The".
    var labelSmall: SKLabelNode?

    /// The label node for the title.
    var labelTitle: SKLabelNode?

    /// The sprite node with the character.
    var character: SKSpriteNode?

    /// The label node for the "Start Game" button.
    var startButton: SKLabelNode?

    /// The label node for the "Options" button.
    var optionsButton: SKLabelNode?

    /// The label node for the "Quit Game" button.
    var quitButton: SKLabelNode?

    /// The Game Center sprite node for the Game Center dashboard.
    /// - Note: This should only be used in older versions of macOS. In macOS 11.0, the GKAccessPoint is used instead.
    var gameCenterButton: SKSpriteNode?

    /// The level of interactivity from this scene.
    private var interactiveLevel: Int = 0

    private var setCharacterAttributes: Bool = false

    /// Instantiate the Game Center access point.
    ///
    /// In macOS 11.0, this will use the native access point and put it in the bottom left. For older versions, a sprite
    /// node will be used to present a game center view.
    func setUpGameCenterProperties() {
        if #available(OSX 11.0, *) {
            self.gameCenterButton?.isHidden = true
            GKAccessPoint.shared.location = .bottomLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            GKAccessPoint.shared.parentWindow = self.view?.window
        }
    }

    override func didMove(to view: SKView) {
        if let gCenter = self.childNode(withName: "gameCenter") as? SKSpriteNode {
            self.gameCenterButton = gCenter
        }

        // Display the Game Center access point.
        self.setUpGameCenterProperties()
    }

    override func sceneDidLoad() {

        // Reset the scale mode to fit accordingly.
        self.scaleMode = .aspectFill

        // Instantiate the appropriate label nodes and add their fonts, respectively.
        if let label = self.childNode(withName: "smallLabel") as? SKLabelNode {
            self.labelSmall = label
            self.labelSmall?.fontName = "Cabin Regular"
        }

        if let title = self.childNode(withName: "titleLabel") as? SKLabelNode {
            self.labelTitle = title
            self.labelTitle?.fontName = "Dancing Script Regular Regular"
        }

        if let start = self.childNode(withName: "startGame") as? SKLabelNode {
            self.startButton = start
            self.startButton?.fontName = "Cabin Regular"
        }

        if let options = self.childNode(withName: "showOptions") as? SKLabelNode {
            self.optionsButton = options
            self.optionsButton?.fontName = "Cabin Regular"
        }

        if let quit = self.childNode(withName: "quitGame") as? SKLabelNode {
            self.quitButton = quit
            self.quitButton?.fontName = "Cabin Regular"
        }

        // Get the character sprite and change the interpolation method to nearest neighbor.
        if let char = self.childNode(withName: "character") as? SKSpriteNode {
            self.character = char

            if AppDelegate.preferences.canShowUnmodeledOnMenu && AppDelegate.preferences.showUnmodeledOnMenu {
                self.character?.texture = SKTexture(imageNamed: "Character_Unmodeled")
            }

            self.character?.texture?.filteringMode = .nearest
        }
    }

    override func mouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        // Hook up the button's location tap to the respective action and run it.
        switch self.atPoint(tappedLocation) {
        case self.startButton:
            self.startAction()
        case self.optionsButton:
            self.optionsAction()
        case self.quitButton:
            quitAction()
        case self.gameCenterButton where self.gameCenterButton?.isHidden != true:
            self.gameCenterAction()
        default:
            break
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        // Grab where the player clicked.
        let tappedLocation = event.location(in: self)

        if self.atPoint(tappedLocation) == self.character {
            if !AppDelegate.preferences.canShowUnmodeledOnMenu {
                self.getCharacterAttributes()
            }
        }
    }

    override func didFinishUpdate() {
        // Update character preferences based on UserDefaults.
        if AppDelegate.preferences.canShowUnmodeledOnMenu {
            self.character?.texture = SKTexture(
                imageNamed: AppDelegate.preferences.showUnmodeledOnMenu
                    ? "Character_Unmodeled"
                    : "Character"
            )
            self.character?.texture?.filteringMode = .nearest
        }
    }

    /// Start the game by presenting the first level scene.
    private func startAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        if #available(OSX 11.0, *) {
            // TODO: Re-enable this once the issue is resolved in GameKit.
            // GKAccessPoint.shared.isActive = false
        }
        if let firstScene = SKScene(fileNamed: "GameScene") {
            // Disable the access point when in an actual level.

            self.removeAllChildren()
            self.view?.presentScene(firstScene, transition: SKTransition.fade(with: .black, duration: 2.0))
        }
    }

    /// Show the app's preferences pane.
    private func optionsAction() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.instantiatePreferencesWindow(self)
        }
    }

    /// Close the application.
    private func quitAction() {
        self.startButton?.fontColor = NSColor.init(named: "AccentColor")
        NSApplication.shared.terminate(nil)
    }

    /// Get the appropriate attributes for the character and update the scene.
    ///
    /// This is primarily inspired by Chumbus from Apollo for iOS where a player has to keep interacting with the
    /// character on the main menu.
    private func getCharacterAttributes() {
        self.interactiveLevel += 1
        var title = ""
        var message = ""

        print(self.interactiveLevel)

        if let menuData = plist(from: "MenuContent") {
            if let data = menuData["Click_\(self.interactiveLevel)"] as? NSDictionary {
                title = data["Title"] as? String ?? ""
                message = data["Message"] as? String ?? ""
                sendAlert(message, withTitle: title, level: .informational) { _ in }
            }
        }

        if self.interactiveLevel == 10000 {
            UserDefaults.standard.setValue(true, forKey: "advShowUnmodeledOnMenuAbility")
            AppDelegate.preferences.showUnmodeledOnMenu = true
            self.character?.texture = SKTexture(imageNamed: "Character_Unmodeled")
            self.character?.texture?.filteringMode = .nearest

            let achivement = GKAchievement(identifier: "costumemaster.face_reveal")
            achivement.percentComplete = 100.0
            GKAchievement.report([achivement]) { error in
                if error != nil {
                    sendAlert(
                        "\(error?.localizedDescription)",
                        withTitle: "Couldn't Sync Achievement",
                        level: .critical
                    ) { _ in }
                }
            }
        }
    }

    // MARK: GAME CENTER

    /// Open the Game Center dashboard.
    /// - Note: This may not works as intended!
    private func gameCenterAction() {
        let gameCenterController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.presentAsSheet(gameCenterController)
        }
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let sceneViewController = self.view?.window?.contentViewController {
            sceneViewController.dismiss(gameCenterViewController)
        }
    }

}
