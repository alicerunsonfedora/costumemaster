//
//  GameScene.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import SpriteKit
import GameplayKit
import Carbon.HIToolbox

/// The base class for a given level.
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
    var switches: [GameSignalSender]?

    /// The level's signal responders.
    var receivers: [GameSignalReceivable]?

    /// The exit door for this level.
    var exitNode: LevelExitDoor?

    /// The walls that encapsulate the player in this level.
    var walls: [SKSpriteNode]?

    /// The list of mappings for each output and the required inputs.
    var requisites: [SwitchRequisite] = []

    // MARK: CONSTRUCTION METHODS

    /// Create children nodes from a tile map node and add them to the scene's view heirarchy.
    private func setupTilemap() {
        // Get the tilemap for this scene.
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKTilemapNode called \"Tile Map Node\" exists.",
                withTitle: "The tilemap for this map is missing.",
                level: .critical) { _ in
                NSApplication.shared.terminate(nil)
            }
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
                    let spritePosition = CGPoint(x: spriteX, y: spriteY)
                    let tileType = getTileType(fromDefinition: defined)

                    // Change the texure's filtering method to allow pixelation.
                    texture.filteringMode = .nearest

                    // Create the sprite node.
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = CGPoint(
                        x: spritePosition.x + origin.x,
                        y: spritePosition.y + origin.y
                    )
                    sprite.zPosition = 1
                    sprite.isHidden = false

                    switch tileType {
                    case .wall:
                        let wallTexture = defined.name == "wall_edge"
                            ? SKTexture(imageNamed: "wall_edge_physics_mask")
                            : texture
                        sprite.physicsBody = getWallPhysicsBody(with: wallTexture)
                        self.walls?.append(sprite)
                    case .player:
                        self.playerNode = Player(
                            texture: texture,
                            allowCostumes: Player.getCostumeSet(id: self.configuration?.costumeID ?? 0),
                            startingWith: self.configuration?.startWithCostume ?? .default
                        )
                        self.playerNode?.position = sprite.position
                        self.playerNode?.zPosition = 2
                        self.playerNode?.isHidden = false
                        self.addChild(self.playerNode!)

                        sprite.texture = SKTexture(imageNamed: "floor")
                        sprite.zPosition = -999
                        self.addChild(sprite)
                    case .floor:
                        sprite.zPosition = -999
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
                        self.receivers?.append(receiver)
                        self.exitNode = receiver
                    default:
                        break
                    }

                    // Add the node to the parent scene's node heirarchy and update the position.
                    if tileType != .player { self.addChild(sprite) }
                }
            }
        }

        // Delete the tilemap from memory.
        tilemap.tileSet = SKTileSet(tileGroups: [])
        tilemap.removeFromParent()
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
            if let correspondingOutputs = self.receivers?.filter({rec in rec.levelPosition == req.outputLocation}) {
                if correspondingOutputs.isEmpty {
                    continue
                }
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

                var output = correspondingOutputs.first

                if let inputs = self.switches?.filter({ (inp: GameSignalSender) in
                                                        req.requiredInputs.contains(inp.levelPosition) }) {
                    if inputs.isEmpty {
                        print("Warn: Inputs for requisite \(req) don't exist.")
                    }
                    for input in inputs {
                        output?.inputs.append(input)
                        output?.activationMethod = req.requisite ?? .noInput
                    }
                }
            }
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
            ) { _ in
                NSApplication.shared.terminate(nil)
            }
            return
        }
        self.configuration = LevelDataConfiguration(from: userData)

        // Get the camera for this scene.
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            sendAlert(
                "Check the appropriate level file and ensure an SKCameraNode called \"Camera\" exists.",
                withTitle: "The camera for this map is missing.",
                level: .critical) { _ in
                NSApplication.shared.terminate(nil)
            }
            return
        }
        self.playerCamera = pCam
        self.playerCamera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))

        // Set up the switches and receivers before parsing the tilemap.
        self.switches = []
        self.receivers = []

        // Set up the list of walls.
        self.walls = []

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
                level: .critical) { _ in
                NSApplication.shared.terminate(self)
            }
            return
        }

        // Update the camera and its position.
        self.camera = playerCamera
        self.playerCamera!.position = self.playerNode!.position
    }

    // MARK: LIFE CYCLE UPDATES

    override func update(_ currentTime: TimeInterval) {
        // Update the camera's position.
        if self.camera?.position != self.playerNode?.position {
            self.camera?.run(SKAction.move(to: self.playerNode?.position ?? CGPoint(x: 0, y: 0), duration: 1))
        }
        self.camera?.setScale(CGFloat(AppDelegate.preferences.cameraScale))
    }

    override func didFinishUpdate() {
        // Run the receiving function on the exit door.
        self.exitNode?.receive(with: self.playerNode, event: nil) { _ in
            if let scene = SKScene(fileNamed: self.configuration?.linksToNextScene ?? "MainMenu") {
                self.view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 2.0))
            }
        }
    }

    // MARK: EVENT TRIGGERS

    /// Check the wall states and update their physics bodies.
    /// - Parameter costume: The costume to run the checks against.
    func checkWallStates(with costume: PlayerCostumeType?) {
        self.walls?.forEach { (wall: SKSpriteNode) in
            wall.physicsBody = costume == .bird
                                ? nil
                                : getWallPhysicsBody(with: wall.texture!)
        }
    }

    public override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {

        // Check for movement keys and move the player node in the respective directions.
        case kVK_ANSI_W, kVK_UpArrow:
            self.playerNode?.move(.north, unit: self.unit!)
        case kVK_ANSI_S, kVK_DownArrow:
            self.playerNode?.move(.south, unit: self.unit!)
        case kVK_ANSI_A, kVK_LeftArrow:
            self.playerNode?.move(.west, unit: self.unit!)
        case kVK_ANSI_D, kVK_RightArrow:
            self.playerNode?.move(.east, unit: self.unit!)

        // Check for the costume switching key and switch to the next available costume.
        case kVK_ANSI_F:
            let costume = self.playerNode?.nextCostume()
            self.checkWallStates(with: costume)
        case kVK_ANSI_G:
            let costume = self.playerNode?.previousCostume()
            self.checkWallStates(with: costume)
        // Catch-all case.
        default:
            break

        }
    }

    public override func keyUp(with event: NSEvent) {
        switch Int(event.keyCode) {

        // Stop movement when a movement key is released.
        case kVK_ANSI_W, kVK_ANSI_S, kVK_ANSI_A, kVK_ANSI_D, kVK_UpArrow, kVK_DownArrow, kVK_LeftArrow, kVK_RightArrow:
            self.playerNode?.halt()
        default:
            break
        }
    }
}
