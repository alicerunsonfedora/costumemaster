//
//  GameScene.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import GameKit
import SpriteKit
import GameplayKit
import KeyboardShortcuts
//import Carbon.HIToolbox

/// The base class for a given level.
///
/// Typically, a level consists of a camera and tilemap which gets parsed into separate nodes. The scene also contains
/// important data that provides additional context for the level's configuration.
/// - Requires: A tile map node called "Tile Map Node". Automapping _should_ be disabled, and the tileset should be
/// "Costumemaster Default".
/// - Requires: A camera node called "Camera".
/// - Requires: `availableCostumes` field in user data: (Int) determines which costumes are available.
/// See also: `Player.getCostumeSet`.
/// - Requires: `levelLink` field in user data: (String) determines the next scene to display after this scene ends.
/// - Requires: `startingCostume` field in user data: (String) determines which costume the player starts with.
/// - Requires: `requisite_COL_ROW` field(s) in user data: (String) determines what outputs require certain inputs.
/// Columns go from left to right, and rows go from bottom to top. The format for a requisite string is
/// `"METHOD;COL,ROW;"`, where `METHOD` can be `AND` or `OR`, and every predicate afterwards is the coordinate
/// to a corresponding input. For example: setting the key `requisite_1_1` to `AND;2,1;3,1;` will tell the scene
/// to connect the output at (1, 1) to the inputs (2, 1) and (3, 1) while also making the connect an `AND` connection
/// where both inputs must be active to activate the output.
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

    /// The exit door for this level.
    var exitNode: LevelExitDoor?

    /// The list of mappings for each output and the required inputs.
    var requisites: [SwitchRequisite] = []

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
                withTitle: "The tilemap for this map is missing.",
                level: .critical) { _ in NSApplication.shared.terminate(nil) }
            return
        }

        // Calculate information about the tilemap's size.
        let mapUnit = tilemap.tileSize
        self.unit = mapUnit
        let mapHalfWidth = CGFloat(tilemap.numberOfColumns) / (mapUnit.width * 2)
        let mapHalfHeight = CGFloat(tilemap.numberOfRows) / (mapUnit.height * 2)
        let origin = tilemap.position

        // Seperate the tilemap into several nodes.
        for col in 0..<tilemap.numberOfColumns {
            for row in 0..<tilemap.numberOfRows {
                if let defined = tilemap.tileDefinition(atColumn: col, row: row) {
                    let texture = defined.textures[0]
                    let spriteX = CGFloat(col) * mapUnit.width - mapHalfWidth + (mapUnit.width / 2)
                    let spriteY = CGFloat(row) * mapUnit.height - mapHalfHeight + (mapUnit.height / 2)
                    let tileType = getTileType(fromDefinition: defined)

                    // Change the texure's filtering method to allow pixelation.
                    texture.filteringMode = .nearest

                    // Create the sprite node.
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = CGPoint(x: spriteX + origin.x, y: spriteY + origin.y)
                    sprite.zPosition = 1
                    sprite.isHidden = false

                    switch tileType {
                    case .wall:
                        let wallTexture = defined.name == "wall_edge" ? "wall_edge_physics_mask" : defined.name!
                        sprite.physicsBody = getWallPhysicsBody(with: wallTexture)
                        sprite.name = "wall_\(col)_\(row)"
                        self.structure.addChild(sprite)
                    case .player:
                        self.playerNode = Player(
                            texture: texture,
                            allowCostumes: Player.getCostumeSet(id: self.configuration?.costumeID ?? 0),
                            startingWith: self.configuration?.startWithCostume ?? .flashDrive
                        )
                        self.playerNode?.position = sprite.position
                        self.addChild(self.playerNode!)
                        sprite.texture = SKTexture(imageNamed: "floor")
                        sprite.zPosition = -999
                        self.addChild(sprite)
                    case .floor:
                        sprite.zPosition = -999
                        self.structure.addChild(sprite)
                    case .exit:
                        let receiver = LevelExitDoor(
                            fromInput: [],
                            reverseSignal: false,
                            baseTexture: "exit",
                            at: CGPoint(x: col, y: row)
                        )
                        receiver.activationMethod = .anyInput
                        receiver.position = sprite.position
                        receiver.playerListener = self.playerNode
                        self.receivers.append(receiver)
                        self.exitNode = receiver
                    case .lever:
                        let definedTextureName = defined.name?.replacingOccurrences(of: "_on", with: "")
                            ?? "lever_wallup"
                        let lever = GameSignalSender(
                            textureName: definedTextureName,
                            by: .activeOncePermanently,
                            at: CGPoint(x: col, y: row)
                        )
                        lever.position = sprite.position
                        lever.kind = .lever
                        if definedTextureName == "lever_wallup" {
                            lever.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
                        }
                        self.switches.append(lever)
                    case .computerT1, .computerT2:
                        let name = defined.name?
                            .replacingOccurrences(of: "_on_T1", with: "")
                            .replacingOccurrences(of: "_on_T2", with: "")
                            ?? "computer_wallup"
                        let computer = GameSignalSender(
                            textureName: name,
                            by: .activeOncePermanently,
                            at: CGPoint(x: col, y: row)
                        )
                        computer.position = sprite.position
                        computer.physicsBody = getWallPhysicsBody(with: "wall_edge_physics_mask")
                        computer.kind = tileType == .computerT1 ? .computerT1 : .computerT2
                        self.switches.append(computer)
                    default:
                        break
                    }
                }
            }
        }

        for node in self.switches { node.zPosition -= 5; self.addChild(node) }
        for node in self.receivers { node.zPosition -= 5; self.addChild(node) }

        // Delete the tilemap from memory.
        tilemap.tileSet = SKTileSet(tileGroups: [])
        tilemap.removeFromParent()

        // Finally, clump all of the non-player sprites under the structure node to prevent scene
        // overbearing.
        self.structure.zPosition = -5
        self.addChild(self.structure)
    }

    // MARK: SWITCH REQUISITE CONSTRUCTORS

    /// Parse the user data for switch requisites and hook up the inputs and outputs accordingly.
    private func parseRequisiteData() {

        // Only run this if there's user data for the scene.
        if let userDataFields = self.userData {

            // Iterate through every key in the user data, looking for "requisite_"
            for key in userDataFields.keyEnumerator() {
                if let keyName = key as? String {
                    if !keyName.starts(with: "requisite_") { continue }

                    // Assume the format of the key is "resuisite_COL_ROW".
                    var parts = keyName.split(separator: "_")
                    parts.removeFirst()
                    if parts.first == nil || parts.last == nil { continue }

                    // Create a tuple of the output location.
                    let outputLocation = CGPoint(x: Int(parts.first!) ?? -1, y: Int(parts.last!) ?? -1)

                    // If we have an associated value for this, parse it.
                    if let valueData = userDataFields.value(forKey: keyName) as? String {

                        // Split the value into parts with the format "METHOD;COL,ROW;COL,ROW".
                        var valueParts = valueData.split(separator: ";")
                        if valueParts.count < 1 { continue }

                        // Determine the method of activation and create an input list.
                        let type = SwitchRequisite.getRequisite(from: String(valueParts.removeFirst()))
                        var inputs: [CGPoint] = []

                        // Parse the inputs, create a tuple, and add it to the input list.
                        for input in valueParts {
                            let coordinates = input.split(separator: ",")
                            if coordinates.count < 2 { continue }
                            inputs.append(
                                CGPoint(x: Int(coordinates.first!) ?? -1, y: Int(coordinates.last!) ?? -1)
                            )
                        }

                        // Finally, stitch together the requisite and add it to the list.
                        self.requisites.append(
                            SwitchRequisite(outputLocation: outputLocation, requiredInputs: inputs, requisite: type)
                        )
                    }
                }
            }
        }
    }

    /// Parse the requisites and hook up the appropriate signal senders to their receivers.
    private func parseRequisites() {
        for req in self.requisites {
            let correspondingOutputs = self.receivers.filter({rec in rec.levelPosition == req.outputLocation})
            if correspondingOutputs.isEmpty { continue }
            if correspondingOutputs.count > 1 {
                sendAlert(
                    "The level configuration has duplicate mappings for the output at \(req.outputLocation)."
                    + " Ensure that the user data file contains the correct mappings.",
                    withTitle: "Duplicate mappings found.",
                    level: .critical
                ) { _ in
                    if let scene = SKScene(fileNamed: "MainMenu") {
                        self.view?.presentScene(scene)
                    }
                }
            }
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

    // MARK: SCENE LOADING

    override func sceneDidLoad() {

        // Set the correct scaling mode.
        self.scaleMode = .resizeFill

        // Instantiate the level configuration.
        guard let userData = self.userData else {
            sendAlert(
                "Check that the level file contains data in the User Data.",
                withTitle: "User Data Missing",
                level: .critical
            ) { _ in NSApplication.shared.terminate(nil) }
            return
        }
        self.configuration = LevelDataConfiguration(from: userData)

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKCameraNode called \"Camera\" exists.",
                withTitle: "The camera for this map is missing.",
                level: .critical) { _ in NSApplication.shared.terminate(nil) }
            return
        }
        self.playerCamera = pCam
        self.playerCamera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))

        // Create switch requisites, parse the tilemap, then hook tp the signals/receivers according to the requisites.
        self.parseRequisiteData()
        self.setupTilemap()
        self.parseRequisites()

        // Check that a player was generated.
        if playerNode == nil {
            sendAlert(
                "Check the appropriate level file and ensure the SKTileMapNode includes a tile definition for the"
                + " player.",
                withTitle: "The player for this map is missing.",
                level: .critical) { _ in NSApplication.shared.terminate(self) }
            return
        }

        // Update the camera and its position.
        self.camera = playerCamera
        self.playerCamera!.position = self.playerNode!.position
    }

    // MARK: LIFE CYCLE UPDATES

    override func update(_ currentTime: TimeInterval) {
        if self.camera?.position != self.playerNode?.position {
            self.camera?.run(SKAction.move(to: self.playerNode?.position ?? CGPoint(x: 0, y: 0), duration: 1))
        }
        self.camera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))
        self.receivers.forEach { output in output.update() }
    }

    override func didFinishUpdate() {
        if self.exitNode?.active == true {
            self.exitNode?.receive(with: self.playerNode, event: nil) { _ in
                if let scene = SKScene(fileNamed: self.configuration?.linksToNextScene ?? "MainMenu") {
                    self.view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 2.0))
                }
            }
        }
    }

    // MARK: EVENT TRIGGERS

    /// Check the wall states and update their physics bodies.
    /// - Parameter costume: The costume to run the checks against.
    func checkWallStates(with costume: PlayerCostumeType?) {
        for node in self.structure.children where node.name != nil && node.name!.starts(with: "wall_") {
            if let wall = node as? SKSpriteNode {
                wall.physicsBody = costume == .bird ? nil : getWallPhysicsBody(with: wall.texture!)
            }
        }
    }

    /// Check the state of the inputs.
    func checkInputStates(_ event: NSEvent) {
        guard let location = self.playerNode?.position else { return }
        let inputs = self.switches
        for input in inputs where input.position.distance(between: location) < (self.unit?.width ?? 128) / 2
            && input.activationMethod != .activeByPlayerIntervention {
            switch input.kind {
            case .lever:
                input.activate(with: event, player: self.playerNode)
            case .computerT1:
                if self.playerNode?.costume == PlayerCostumeType.bird {
                    input.activate(with: event, player: self.playerNode)
                }
            case .computerT2:
                if self.playerNode?.costume == PlayerCostumeType.flashDrive {
                    input.activate(with: event, player: self.playerNode)
                }
            default:
                break
            }
        }
    }

    public override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case KeyboardShortcuts.getShortcut(for: .moveUp)?.carbonKeyCode:
            self.playerNode?.move(.north, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveDown)?.carbonKeyCode:
            self.playerNode?.move(.south, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveLeft)?.carbonKeyCode:
            self.playerNode?.move(.west, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .moveRight)?.carbonKeyCode:
            self.playerNode?.move(.east, unit: self.unit!)
        case KeyboardShortcuts.getShortcut(for: .nextCostume)?.carbonKeyCode:
            let costume = self.playerNode?.nextCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .previousCostume)?.carbonKeyCode:
            let costume = self.playerNode?.previousCostume()
            self.checkWallStates(with: costume)
        case KeyboardShortcuts.getShortcut(for: .use)?.carbonKeyCode:
            checkInputStates(event)
        default:
            break

        }
    }

    public override func keyUp(with event: NSEvent) {
        let movementKeys = [
            KeyboardShortcuts.getShortcut(for: .moveUp)?.carbonKeyCode,
            KeyboardShortcuts.getShortcut(for: .moveLeft)?.carbonKeyCode,
            KeyboardShortcuts.getShortcut(for: .moveRight)?.carbonKeyCode,
            KeyboardShortcuts.getShortcut(for: .moveDown)?.carbonKeyCode
        ]
        if movementKeys.contains(Int(event.keyCode)) {
            self.playerNode?.halt()
        }
    }
}
