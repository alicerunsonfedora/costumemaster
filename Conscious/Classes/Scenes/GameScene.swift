//
//  GameScene.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CranberrySprite
import GameKit
import GameplayKit
import KeyboardShortcuts
import SpriteKit

/// The base class for a given level.
///
/// - Requires: A tile map node called "Tile Map Node". Automapping _should_ be disabled, and the tileset should be
/// "Costumemaster Default".
/// - Requires: A camera node called "Camera".
/// - Requires: Level configuration data in the scene's user data. See also: `LevelDataConfiguration`.
class GameScene: SKScene {
    // MARK: STORED PROPERTIES

    /// The player node in the level.
    var playerNode: Player?

    /// The base unit size for a given tile in a level.
    var unit: CGSize?

    /// The configuration for this level.
    var configuration: LevelDataConfiguration?

    /// The level's signal senders.
    var switches: [GameSignalSender] = []

    /// The level's signal responders.
    var receivers: [GameSignalReceivable] = []

    /// Interactable objects in the level.
    var interactables: [GameHeavyObject] = []

    /// The exit door for this level.
    var exitNode: DoorReceiver?

    /// A child node that stores the structure of the level.
    var structure: SKNode = .init()

    /// Whether the player has died on this level.
    var playerDied: Bool = false

    /// The tile map node that contains the information about the world.
    var world: CSTileMapParseable?

    // MARK: SWITCH REQUISITE HANDLERS

    /// Parse the requisites and hook up the appropriate signal senders to their receivers.
    private func linkSignalsAndReceivers() {
        guard let requisites = configuration?.requisites else { return }
        for req in requisites {
            let correspondingOutputs = receivers.filter { rec in rec.worldPosition == req.outputLocation }
            if correspondingOutputs.isEmpty { continue }
            let output = correspondingOutputs.first
            let inputs = switches
            if inputs.isEmpty { continue }
            for input in inputs where req.requiredInputs.contains(input.worldPosition) {
                output?.inputs.append(input)
                output?.activationMethod = req.requisite ?? .noInput
            }
            output?.updateInputs()
        }
    }

    // MARK: SCENE LOADING

    /// Set up the game scene, parse the tilemapm and start playing music.
    override func sceneDidLoad() {
        // Set the correct scaling mode.
        scaleMode = .aspectFill

        if let skybox = NSColor(named: "Skybox") { backgroundColor = skybox }

        // Instantiate the level configuration.
        guard let userData = userData else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.user_data_missing_error", comment: "User data missing"),
                withTitle: NSLocalizedString("costumemaster.alert.user_data_missing_error_title", comment: "User data missing title"),
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }
        configuration = LevelDataConfiguration(from: userData)

        // Get the tilemap for this scene.
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.tilemap_missing_error", comment: "Tile map missing"),
                withTitle: NSLocalizedString("costumemaster.alert.tilemap_missing_error_title", comment: "Tile map missing title"),
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }
        world = tilemap

        // Create switch requisites, parse the tilemap, then hook tp the signals/receivers according to the requisites.
        generateWorld()
        linkSignalsAndReceivers()

        // Check that a player was generated.
        if playerNode == nil {
            sendAlert(
                NSLocalizedString("costumemaster.alert.player_missing_error", comment: "Player missing")
                    + "",
                withTitle: NSLocalizedString("costumemaster.alert.player_missing_error_title", comment: "Player missing title"),
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.camera_missing_error", comment: "Camera missing"),
                withTitle: NSLocalizedString("costumemaster.alert.camera_missing_error_title", comment: "Camera missing title"),
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }
        camera = pCam
        camera?.setScale(
            CGFloat(
                UserDefaults.cameraScale.clamp(lower: 0.25, upper: 1.0)
            )
        )
        camera?.position = playerNode!.position
        let bounds = SKRange(
            lowerLimit: 0, upperLimit: UserDefaults.intelligentCamera
                ? 256 * CGFloat(UserDefaults.cameraScale) : 0
        )
        camera?.constraints = [SKConstraint.distance(bounds, to: playerNode!)]

        if let dustEmitter = SKEmitterNode(fileNamed: "Dust") {
            dustEmitter.name = "dust"
            dustEmitter.zPosition = 100; dustEmitter.alpha = 0.15
            dustEmitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            let drift = SKConstraint.distance(SKRange(upperLimit: 512), to: camera!)
            dustEmitter.constraints = [drift]
            camera?.addChild(dustEmitter)
        }

        let music = SKAudioNode(
            fileNamed: configuration?.trackName ?? (["minute", "phase"].randomElement() ?? "minute")
        )
        music.name = "music"
        music.autoplayLooped = true; music.isPositional = false
        music.run(SKAction.sequence([
            SKAction.changeVolume(to: UserDefaults.musicVolume, duration: 0.01),
            SKAction.play(),
        ]))
        addChild(music)
    }

    // MARK: LIFE CYCLE UPDATES

    /// Run scene-related lifecycle updates.
    override func update(_: TimeInterval) {
        camera?.setScale(CGFloat(UserDefaults.standard.float(forKey: "cameraScale")))
        receivers.forEach { output in output.update() }
        playerNode?.update()

        if let music = childNode(withName: "music") as? SKAudioNode {
            music.run(
                SKAction.changeVolume(to: UserDefaults.standard.float(forKey: "soundMusicVolume"), duration: 0.01)
            )
        }

        let bounds = SKRange(
            lowerLimit: 0, upperLimit: UserDefaults.standard.bool(forKey: "intelligentCameraMovement")
                ? 256 * CGFloat(UserDefaults.standard.float(forKey: "cameraScale")) : 0
        )
        camera?.constraints = [SKConstraint.distance(bounds, to: playerNode!)]
        camera?.childNode(withName: "dust")?.alpha = UserDefaults.dustParticles ? 0.15 : 0
    }

    /// Run any post-update logic and check input states.
    override func didFinishUpdate() {
        for input in switches where input.activationMethod.contains(.activeByPlayerIntervention) {
            if [GameSignalKind.pressurePlate, GameSignalKind.trigger].contains(input.kind),
               !(input is GameIrisScanner)
            {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            } else if input is GameIrisScanner,
                      input.shouldActivateOnIntervention(with: self.playerNode, objects: self.interactables)
            {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            }
        }
        checkDoorStates()
        if exitNode?.active == true {
            exitNode?.receive(with: playerNode, event: nil) { _ in
                self.callScene(name: self.configuration?.linksToNextScene)
            }
        }
        for child in structure.children where child is GameDeathPit {
            guard let pit = child as? GameDeathPit else { continue }
            if pit.shouldKill(self.playerNode), !self.playerDied {
                self.kill()
            }
        }
    }

    /// Prepare the scene for destruction and save the scene name.
    override func willMove(from _: SKView) {
        guard let name = scene?.name else { return }
        GameStore.shared.lastSavedScene = name.starts(with: "b_") ? GameStore.shared.lastSavedScene : name
    }

    /// Call the scene with a given file name.
    /// - Parameter name: The file name of the scene to call.
    func callScene(name: String?) {
        guard let scene = SKScene(fileNamed: name ?? "MainMenu") else { return }
        if let music = childNode(withName: "music") as? SKAudioNode {
            music.run(SKAction.changeVolume(to: 0.0, duration: 0.25))
        }
        view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 1.5))
    }
}
