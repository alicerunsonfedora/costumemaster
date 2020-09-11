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

    /// The camera attached to the player.
    var playerCamera: SKCameraNode?

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

    // MARK: CONSTRUCTION METHODS
    /// Create children nodes from a tile map node and add them to the scene's view heirarchy.
    private func setupTilemap() {
        // swiftlint:disable:previous cyclomatic_complexity

        // Get the tilemap for this scene.
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKTilemapNode called \"Tile Map Node\" exists.",
                withTitle: "The tilemap for the map \"\(self.name ?? "GameScene")\" is missing.",
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }

        // Instantiate the unit first.
        let mapUnit = tilemap.tileSize
        self.unit = mapUnit

        // Parse the tilemap and set up the nodes accordingly.
        tilemap.parse { (data: TilemapParseData) in
            // Offset by one to prevent texture collisions.
            data.sprite.size = CGSize(width: data.unit.width + 1, height: data.unit.height + 1)

            switch getTileType(fromDefinition: data.definition) {
            case .wall:
                guard let wallName = data.definition.name else { return }
                let wallTexture = wallName.starts(with: "wall_edge") ? "wall_edge_physics_mask" : wallName
                data.sprite.physicsBody = getWallPhysicsBody(with: wallTexture)
                data.sprite.name = "wall_\(data.column)_\(data.row)\(wallName.starts(with: "wall_edge") ? "_edge": ""))"
                self.structure.addChild(data.sprite)
            case .player:
                self.playerNode = Player(
                    texture: data.texture,
                    allowCostumes: Player.getCostumeSet(id: self.configuration?.costumeID ?? 0),
                    startingWith: self.configuration?.startWithCostume ?? .flashDrive
                )
                self.playerNode?.position = data.sprite.position
                self.playerNode?.size = data.sprite.size
                self.addChild(self.playerNode!)
                data.sprite.texture = SKTexture(imageNamed: "floor")
                data.sprite.zPosition = -999
                self.addChild(data.sprite)
            case .triggerGameCenter:
                let trigger = GameAchievementTrigger(
                    with: self.configuration?.achievementTrigger,
                    at: CGPoint(x: data.column, y: data.row)
                )
                trigger.position = data.sprite.position
                trigger.size = data.sprite.size
                self.switches.append(trigger)
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

        for node in self.receivers where node.levelPosition == self.configuration?.exitLocation {
            if let door = node as? DoorReceiver { self.exitNode = door }
        }

        // Delete the tilemap from memory.
        tilemap.tileSet = SKTileSet(tileGroups: [])
        tilemap.removeFromParent()

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
                let correspondingOutputs = self.receivers.filter({rec in rec.levelPosition == req.outputLocation})
                if correspondingOutputs.isEmpty { continue }
                let output = correspondingOutputs.first
                let inputs = self.switches
                if inputs.isEmpty { continue }
                for input in inputs where req.requiredInputs.contains(input.levelPosition) {
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

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKCameraNode called \"Camera\" exists.",
                withTitle: "The camera for the map \"\(self.name ?? "GameScene")\" is missing.",
                level: .critical) { _ in self.callScene(name: "MainMenu") }
            return
        }
        self.playerCamera = pCam
        self.playerCamera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))

        // Create switch requisites, parse the tilemap, then hook tp the signals/receivers according to the requisites.
        self.setupTilemap()
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

        // Update the camera and its position.
        self.camera = playerCamera
        self.playerCamera!.position = self.playerNode!.position

        let music = SKAudioNode(fileNamed: ["September", "November"].randomElement() ?? "September")
        music.name = "music"
        music.autoplayLooped = true; music.isPositional = false
        music.run(SKAction.sequence([
            SKAction.changeVolume(to: AppDelegate.preferences.musicVolume, duration: 0.01),
            SKAction.play()
        ]))
        self.addChild(music)
    }

    // MARK: LIFE CYCLE UPDATES
    /// Run scene-related lifecycle updates.
    override func update(_ currentTime: TimeInterval) {
        if self.camera?.position != self.playerNode?.position {
            self.camera?.run(SKAction.move(to: self.playerNode?.position ?? CGPoint(x: 0, y: 0), duration: 1))
        }
        self.camera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))
        self.receivers.forEach { output in output.update() }
        self.playerNode?.update()
        if let music = self.childNode(withName: "music") as? SKAudioNode {
            music.run(SKAction.changeVolume(to: AppDelegate.preferences.musicVolume, duration: 0.01))
        }
    }

    /// Run any post-update logic and check input states.
    override func didFinishUpdate() {
        for input in self.switches where input.activationMethod == .activeByPlayerIntervention {
            switch input.kind {
            case .pressurePlate, .trigger:
                input.activate(with: nil, player: self.playerNode, objects: self.interactables)
            default:
                break
            }
        }
        self.checkDoorStates()
        if self.exitNode?.active == true {
            self.exitNode?.receive(with: self.playerNode, event: nil) { _ in
                self.callScene(name: self.configuration?.linksToNextScene)
            }
        }
    }

    /// Prepare the scene for destruction and save the scene name.
    override func willMove(from view: SKView) {
        guard let name = self.scene?.name else { return }
        GameStore.shared.lastSavedScene = name.starts(with: "b_") ? GameStore.shared.lastSavedScene : name
    }

    // MARK: EVENT TRIGGERS
    /// Check the wall states and update their physics bodies.
    /// - Parameter costume: The costume to run the checks against.
    func checkWallStates(with costume: PlayerCostumeType?) {
        for node in self.structure.children where node.name != nil && node.name!.starts(with: "wall_") {
            guard let wall = node as? SKSpriteNode else { return }
            guard let name = wall.name else { return }
            let body = name.contains("_edge") ? "wall_edge_physics_mask" : "wall_top"
            wall.physicsBody = costume == .bird ? nil : getWallPhysicsBody(with: body)
        }
    }

    /// Check the state of the doors in the level.
    func checkDoorStates() {
        for node in self.receivers where node is DoorReceiver && node != self.exitNode {
            guard let door = node as? DoorReceiver else { return }; door.togglePhysicsBody()
        }
    }

    /// Check the state of the inputs.
    func checkInputStates(_ event: NSEvent) {
        var didTrigger = false
        guard let location = self.playerNode?.position else { return }
        let inputs = self.switches
        for input in inputs where input.position.distance(between: location) < (self.unit?.width ?? 128) / 2
            && input.activationMethod != .activeByPlayerIntervention {
            didTrigger = true
            switch input.kind {
            case .lever:
                input.activate(with: event, player: self.playerNode)
            case .computerT1, .computerT2:
                switch self.playerNode?.costume {
                case .bird where input.kind == .computerT1, .flashDrive where input.kind == .computerT2:
                    input.activate(with: event, player: self.playerNode)
                default:
                    self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false))
                }
            case .alarmClock:
                input.activate(with: event, player: self.playerNode)
            default:
                self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false))
            }
        }
        if !didTrigger { self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false)) }
    }

    private func grabItems() {
        for item in interactables {
            if item.carrying { item.resign(from: self.playerNode )} else { item.attach(to: self.playerNode) }
        }
    }

    private func getPauseScene() {
        guard let controller = self.view?.window?.contentViewController as? ViewController else { return }
        controller.rootScene = self; self.callScene(name: "PauseMenu")
    }

    private func callScene(name: String?) {
        guard let scene = SKScene(fileNamed: name ?? "MainMenu") else { return }
        if let music = self.childNode(withName: "music") as? SKAudioNode {
            music.run(SKAction.changeVolume(to: 0.0, duration: 0.25))
        }
        self.view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 1.5))
    }

    /// Listen to keyboard events and run the game logic for key events.
    public override func keyDown(with event: NSEvent) {
        guard let changing = self.playerNode?.isChangingCostumes else { return }
        switch Int(event.keyCode) {
        case KeyboardShortcuts.getShortcut(for: .moveUp)?.carbonKeyCode where !changing:
            self.playerNode?.move(.north, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveDown)?.carbonKeyCode where !changing:
            self.playerNode?.move(.south, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveLeft)?.carbonKeyCode where !changing:
            self.playerNode?.move(.west, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveRight)?.carbonKeyCode where !changing:
            self.playerNode?.move(.east, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .nextCostume)?.carbonKeyCode:
            let costume = self.playerNode?.nextCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .previousCostume)?.carbonKeyCode:
            let costume = self.playerNode?.previousCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .use)?.carbonKeyCode:
            self.checkInputStates(event)
            self.grabItems()
        case KeyboardShortcuts.getShortcut(for: .pause)?.carbonKeyCode:
            self.getPauseScene()
        default:
            break

        }
    }

    /// Listen for keyboard events and halt the player if the movement keys were released.
    public override func keyUp(with event: NSEvent) {
        let movementKeys = KeyboardShortcuts.movementKeys.map { key in key?.carbonKeyCode }
        if movementKeys.contains(Int(event.keyCode)) { self.playerNode?.halt() }
    }
}
