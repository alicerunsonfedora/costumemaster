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
                guard let wallName = data.definition.name else { return }
                let wallTexture = wallName.starts(with: "wall_edge") ? "wall_edge_physics_mask" : wallName
                let wall = GameStructureObject(with: data.sprite.texture, size: data.sprite.size)
                if wallName.contains("passable") {
                    wall.locked = false
                }
                wall.position = data.sprite.position
                wall.instantiateBody(with: getWallPhysicsBody(with: wallTexture))
                wall.name = "wall_\(data.column)_\(data.row)\(wallName.starts(with: "wall_edge") ? "_edge": ""))"
                wall.worldPosition = CGPoint(x: data.column, y: data.row)

                if wallName.contains("dbroken"), let sparks = SKEmitterNode(fileNamed: "ElectricalSpark") {
                    sparks.zPosition = 100
                    sparks.position = CGPoint(x: wall.position.x + 40, y: wall.position.y - 16)
                    self.addChild(sparks)
                }

                self.structure.addChild(wall)

            case .player:
                self.playerNode = Player(
                    texture: data.texture,
                    allowCostumes: Player.getCostumeSet(id: self.configuration?.costumeID ?? 0),
                    startingWith: self.configuration?.startWithCostume ?? .flashDrive
                )
                self.playerNode?.position = data.sprite.position
                self.playerNode?.size = data.sprite.size
                if let disallow = self.configuration?.disallowCostume {
                    self.playerNode?.remove(costume: disallow)
                }
                self.addChild(self.playerNode!)
                data.sprite.texture = SKTexture(imageNamed: "floor")
                data.sprite.zPosition = -999
                self.addChild(data.sprite)

            case .triggerGameCenter:
                let trigger = GameAchievementTrigger(
                    with: self.configuration?.achievementTrigger, at: CGPoint(x: data.column, y: data.row)
                )
                trigger.position = data.sprite.position
                trigger.size = data.sprite.size
                self.switches.append(trigger)

            case .deathPit, .triggerKill:
                let killer = GameDeathPit(color: .clear, size: data.sprite.size)
                killer.trigger = type == .triggerKill
                if type == .deathPit {
                    killer.texture = data.sprite.texture
                }
                killer.zPosition = -999
                killer.position = data.sprite.position
                self.structure.addChild(killer)

            case .floor:
                data.sprite.zPosition = -999
                self.structure.addChild(data.sprite)

            case .door:
                let receiver = DoorReceiver(
                    fromInput: [],
                    reverseSignal: false,
                    baseTexture: "door",
                    at: CGPoint(x: data.column, y: data.row)
                )
                receiver.activationMethod = .anyInput
                receiver.position = data.sprite.position
                receiver.playerListener = self.playerNode
                receiver.size = data.sprite.size
                self.receivers.append(receiver)

            case .lever:
                let lever = GameLever(at: CGPoint(x: data.column, y: data.row))
                lever.position = data.sprite.position
                lever.size = data.sprite.size
                self.switches.append(lever)

            case .alarmClock:
                let alarm = GameAlarmClock(
                    with: self.configuration?.defaultTimerDelay ?? 3.0,
                    at: CGPoint(x: data.column, y: data.row)
                )
                alarm.position = data.sprite.position
                alarm.size = data.sprite.size
                self.switches.append(alarm)

            case .computerT1, .computerT2:
                let computer = GameComputer(
                    at: CGPoint(x: data.column, y: data.row),
                    with: getTileType(fromDefinition: data.definition) == .computerT1
                )
                computer.position = data.sprite.position
                computer.size = data.sprite.size
                self.switches.append(computer)

            case .pressurePlate:
                let plate = GamePressurePlate(at: CGPoint(x: data.column, y: data.row))
                plate.position = data.sprite.position
                plate.size = data.sprite.size
                self.switches.append(plate)

            case .biometricScanner:
                let iris = GameIrisScanner(at: CGPoint(x: data.column, y: data.row))
                iris.position = data.sprite.position
                iris.size = data.sprite.size
                self.switches.append(iris)

            case .heavyObject:
                let object = GameHeavyObject(
                    with: data.definition.name?.replacingOccurrences(of: "floor_ho_", with: "") ?? "cabinet",
                    at: CGPoint(x: data.column, y: data.row)
                )
                object.position = data.sprite.position
                object.zPosition = self.playerNode?.zPosition ?? 5
                object.size = data.sprite.size
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
        if let requisites = self.configuration?.requisites {
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
                "Check that the level file contains data in the User Data.",
                withTitle: "The properties for \"\(self.name ?? "GameScene")\" are missing.",
                level: .critical
            ) { _ in self.callScene(name: "MainMenu") }
            return
        }
        self.configuration = LevelDataConfiguration(from: userData)

        // Get the tilemap for this scene.
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKTilemapNode called \"Tile Map Node\" exists.",
                withTitle: "The tilemap for the map \"\(self.name ?? "GameScene")\" is missing.",
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Create switch requisites, parse the tilemap, then hook tp the signals/receivers according to the requisites.
        self.setupTilemap(tilemap: tilemap)
        self.linkSignalsAndReceivers()

        // Check that a player was generated.
        if playerNode == nil {
            sendAlert(
                "Check the appropriate level file and ensure the SKTileMapNode includes a tile definition for the"
                + " player.",
                withTitle: "The player for the map \"\(self.name ?? "GameScene")\" is missing.",
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKCameraNode called \"Camera\" exists.",
                withTitle: "The camera for the map \"\(self.name ?? "GameScene")\" is missing.",
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
