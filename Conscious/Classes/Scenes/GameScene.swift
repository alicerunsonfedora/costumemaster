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

    var exitNode: LevelExitDoor?

    var walls: [SKSpriteNode]?

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
                        sprite.physicsBody = getWallPhysicsBody(with: texture)
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
                    case .exit:
                        let receiver = LevelExitDoor(
                            fromInput: self.switches ?? [],
                            reverseSignal: false,
                            baseTexture: "exit"
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
        self.playerCamera?.setScale(0.5)

        // Set up the switches and receivers before parsing the tilemap.
        self.switches = []
        self.receivers = []

        // Set up the list of walls.
        self.walls = []

        self.setupTilemap()

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

    override func update(_ currentTime: TimeInterval) {
        // Update the camera's position.
        if self.camera?.position != self.playerNode?.position {
            self.camera?.run(SKAction.move(to: self.playerNode?.position ?? CGPoint(x: 0, y: 0), duration: 1))
        }
    }

    override func didFinishUpdate() {
        // Run the receiving function on the exit door.
        self.exitNode?.receive(with: self.playerNode, event: nil) { _ in
            if let scene = SKScene(fileNamed: self.configuration?.linksToNextScene ?? "MainMenu") {
                self.view?.presentScene(scene, transition: SKTransition.fade(with: .black, duration: 2.0))
            }
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