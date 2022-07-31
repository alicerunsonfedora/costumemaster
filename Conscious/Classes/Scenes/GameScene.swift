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

import GameKit
import SpriteKit
import GameplayKit
import KeyboardShortcuts
import GBMKUtils

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
    var structure: SKNode = SKNode()

    /// Whether the player has died on this level.
    var playerDied: Bool = false

    // MARK: CONSTRUCTION METHODS
    /// Create children nodes from a tile map node and add them to the scene's view heirarchy.
    private func setupTilemap(tilemap: SKTileMapNode) {
        // swiftlint:disable:previous cyclomatic_complexity

        // Instantiate the unit first.
        let mapUnit = tilemap.tileSize; self.unit = mapUnit

        // Parse the tilemap and set up the nodes accordingly.
        tilemap.parse { (data: GBMKTilemapParseData) in
            // Offset by one to prevent texture collisions.
            data.sprite.size = CGSize(width: data.unit.width + 1, height: data.unit.height + 1)
            let type = getTileType(fromDefinition: data.definition)

            switch type {
            case .wall:
                guard let wall = makeWall(from: data) else { return }
                self.structure.addChild(wall)

            case .player:
                self.playerNode = makePlayer(from: data, with: configuration)
                self.addChild(self.playerNode!)
                data.sprite.texture = SKTexture(imageNamed: "floor")
                data.sprite.zPosition = -999
                self.addChild(data.sprite)

            case .triggerGameCenter:
                guard let trigger = makeGameCenterTrigger(from: data, with: configuration) else {
                    return
                }
                self.switches.append(trigger)

            case .deathPit, .triggerKill:
                guard let killer = makeDeathPit(from: data, type: type) else {
                    return
                }
                self.structure.addChild(killer)

            case .floor:
                data.sprite.zPosition = -999
                self.structure.addChild(data.sprite)

            case .door:
                guard let receiver = makeDoor(from: data) else { return }
                receiver.playerListener = self.playerNode
                self.receivers.append(receiver)

            case .lever:
                guard let lever = makeLever(from: data) else { return }
                self.switches.append(lever)

            case .alarmClock:
                guard let alarm = makeAlarmClock(from: data) else { return }
                self.switches.append(alarm)

            case .computerT1, .computerT2:
                guard let computer = makeComputer(from: data, type: type) else { return }
                self.switches.append(computer)

            case .pressurePlate:
                guard let plate = makePressurePlate(from: data) else { return }
                self.switches.append(plate)

            case .biometricScanner:
                guard let iris = makeBiometrics(from: data) else { return }
                self.switches.append(iris)

            case .heavyObject:
                guard let object = makeHeavyObject(from: data) else { return }
                self.interactables.append(object)
                data.sprite.texture = SKTexture(imageNamed: "floor")
                data.sprite.zPosition = -999
                self.addChild(data.sprite)
            default:
                break
            }
        }

        for node in self.switches { node.zPosition -= 5; self.addChild(node) }
        for node in self.receivers { node.zPosition -= 5; self.addChild(node) }
        for node in self.interactables { self.addChild(node) }

        for node in self.receivers where node.worldPosition == self.configuration?.exitLocation {
            if let door = node as? DoorReceiver { self.exitNode = door }
        }

        // Delete the tilemap from memory.
        tilemap.tileSet = SKTileSet(tileGroups: []); tilemap.removeFromParent()

        // Finally, clump all of the non-player sprites under the structure node to prevent scene
        // overbearing.
        self.structure.zPosition = -5
        self.addChild(self.structure)
    }

    // MARK: SWITCH REQUISITE HANDLERS
    /// Parse the requisites and hook up the appropriate signal senders to their receivers.
    private func linkSignalsAndReceivers() {
        guard let requisites = self.configuration?.requisites else { return }
        for req in requisites {
            let correspondingOutputs = self.receivers.filter({rec in rec.worldPosition == req.outputLocation})
            if correspondingOutputs.isEmpty { continue }
            let output = correspondingOutputs.first
            let inputs = self.switches
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
        self.scaleMode = .aspectFill

        if let skybox = NSColor(named: "Skybox") { self.backgroundColor = skybox }

        // Instantiate the level configuration.
        guard let userData = self.userData else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.user_data_missing_error", comment: "User data missing"),
                withTitle: NSLocalizedString("costumemaster.alert.user_data_missing_error_title", comment: "User data missing title"),
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }
        self.configuration = LevelDataConfiguration(from: userData)

        // Get the tilemap for this scene.
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.tilemap_missing_error", comment: "Tile map missing"),
                withTitle: NSLocalizedString("costumemaster.alert.tilemap_missing_error_title", comment: "Tile map missing title"),
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Create switch requisites, parse the tilemap, then hook tp the signals/receivers according to the requisites.
        self.setupTilemap(tilemap: tilemap)
        self.linkSignalsAndReceivers()

        // Check that a player was generated.
        if playerNode == nil {
            sendAlert(
                NSLocalizedString("costumemaster.alert.player_missing_error", comment: "Player missing")
                + "",
                withTitle: NSLocalizedString("costumemaster.alert.player_missing_error_title", comment: "Player missing title"),
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                NSLocalizedString("costumemaster.alert.camera_missing_error", comment: "Camera missing"),
                withTitle: NSLocalizedString("costumemaster.alert.camera_missing_error_title", comment: "Camera missing title"),
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }
        self.camera = pCam
        self.camera?.setScale(
            CGFloat(
                UserDefaults.cameraScale.clamp(lower: 0.25, upper: 1.0)
            )
        )
        self.camera?.position = self.playerNode!.position
        let bounds = SKRange(
            lowerLimit: 0, upperLimit: UserDefaults.intelligentCamera
                ? 256 * CGFloat(UserDefaults.cameraScale) : 0
        )
        self.camera?.constraints = [SKConstraint.distance(bounds, to: self.playerNode!)]

        if let dustEmitter = SKEmitterNode(fileNamed: "Dust") {
            dustEmitter.name = "dust"
            dustEmitter.zPosition = 100; dustEmitter.alpha = 0.15
            dustEmitter.particlePositionRange = CGVector(dx: self.size.width, dy: self.size.height)
            let drift = SKConstraint.distance(SKRange(upperLimit: 512), to: self.camera!)
            dustEmitter.constraints = [drift]
            self.camera?.addChild(dustEmitter)
        }

        let music = SKAudioNode(
            fileNamed: self.configuration?.trackName ?? (["minute", "phase"].randomElement() ?? "minute")
        )
        music.name = "music"
        music.autoplayLooped = true; music.isPositional = false
        music.run(SKAction.sequence([
            SKAction.changeVolume(to: UserDefaults.musicVolume, duration: 0.01),
            SKAction.play()
        ]))
        self.addChild(music)
    }

    // MARK: LIFE CYCLE UPDATES
    /// Run scene-related lifecycle updates.
    override func update(_ currentTime: TimeInterval) {
        self.camera?.setScale(CGFloat(UserDefaults.standard.float(forKey: "cameraScale")))
        self.receivers.forEach { output in output.update() }
        self.playerNode?.update()

        if let music = self.childNode(withName: "music") as? SKAudioNode {
            music.run(
                SKAction.changeVolume(to: UserDefaults.standard.float(forKey: "soundMusicVolume"), duration: 0.01)
            )
        }

        let bounds = SKRange(
            lowerLimit: 0, upperLimit: UserDefaults.standard.bool(forKey: "intelligentCameraMovement")
                ? 256 * CGFloat(UserDefaults.standard.float(forKey: "cameraScale")) : 0
        )
        self.camera?.constraints = [SKConstraint.distance(bounds, to: self.playerNode!)]
        self.camera?.childNode(withName: "dust")?.alpha = UserDefaults.dustParticles ? 0.15 : 0
    }

    /// Run any post-update logic and check input states.
    override func didFinishUpdate() {
        for input in self.switches where input.activationMethod.contains(.activeByPlayerIntervention) {
            if [GameSignalKind.pressurePlate, GameSignalKind.trigger].contains(input.kind)
                && !(input is GameIrisScanner) {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            } else if input is GameIrisScanner &&
                        input.shouldActivateOnIntervention(with: self.playerNode, objects: self.interactables) {
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            }
        }
        self.checkDoorStates()
        if self.exitNode?.active == true {
            self.exitNode?.receive(with: self.playerNode, event: nil) { _ in
                self.callScene(name: self.configuration?.linksToNextScene)
            }
        }
        for child in self.structure.children where child is GameDeathPit {
            guard let pit = child as? GameDeathPit else { continue }
            if pit.shouldKill(self.playerNode) && !self.playerDied {
                self.kill()
            }
        }
    }

    /// Prepare the scene for destruction and save the scene name.
    override func willMove(from view: SKView) {
        guard let name = self.scene?.name else { return }
        GameStore.shared.lastSavedScene = name.starts(with: "b_") ? GameStore.shared.lastSavedScene : name
    }

    /// Call the scene with a given file name.
    /// - Parameter name: The file name of the scene to call.
    func callScene(name: String?) {
        guard let scene = SKScene(fileNamed: name ?? "MainMenu") else { return }
        if let music = self.childNode(withName: "music") as? SKAudioNode {
            music.run(SKAction.changeVolume(to: 0.0, duration: 0.25))
        }
        self.view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 1.5))
    }
}
