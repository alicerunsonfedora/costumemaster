//
//  GameScene.swift
//  Conscious
//
//  Created by Marquis Kurt on 6/28/20.
//

import SpriteKit
import GameplayKit
import Carbon.HIToolbox

class GameScene: SKScene {
    
    var playerNode: Player?
    var playerCamera: SKCameraNode?
    var unit: CGSize?
    
    override func sceneDidLoad() {
        guard let pCam = childNode(withName: "Camera") as? SKCameraNode else {
            fatalError("Player camera is missing.")
        }
        self.playerCamera = pCam
        self.playerCamera?.setScale(0.5)
        
        guard let tilemap = childNode(withName: "Tile Map Node") as? SKTileMapNode else {
            fatalError("Tile map is missing.")
        }
        
        let mapUnit = tilemap.tileSize
        self.unit = mapUnit
        let mapHalfWidth = CGFloat(tilemap.numberOfColumns) / (mapUnit.width * 2)
        let mapHalfHeight = CGFloat(tilemap.numberOfRows) / (mapUnit.height * 2)
        let origin = tilemap.position
        
        for y in 0..<tilemap.numberOfColumns {
            for x in 0..<tilemap.numberOfRows {
                if let defined = tilemap.tileDefinition(atColumn: y, row: x) {
                    let texture = defined.textures[0]
                    let _x = CGFloat(y) * mapUnit.width - mapHalfWidth + (mapUnit.width / 2)
                    let _y = CGFloat(x) * mapUnit.height - mapHalfHeight + (mapUnit.height / 2)
                    let spritePosition = CGPoint(x: _x, y: _y)
                    
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = spritePosition
                    sprite.zPosition = 1
                    sprite.isHidden = false
                    
                    if ((defined.name?.contains("wall")) != nil) {
                        let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
                        physicsBody.restitution = 0
                        physicsBody.linearDamping = 1000
                        physicsBody.friction = 0.7
                        
                        physicsBody.affectedByGravity = false
                        physicsBody.isDynamic = false
                        physicsBody.isResting = true
                        physicsBody.allowsRotation = false
                        sprite.physicsBody = physicsBody
                    }
                    
                    self.addChild(sprite)
                    sprite.position = CGPoint(x: spritePosition.x + origin.x, y: spritePosition.y + origin.y)
                    
                    if (defined.name == "Main") {
                        self.playerNode = Player(texture: texture)
                        self.playerNode?.position = sprite.position
                        self.playerNode?.zPosition = 1
                        self.playerNode?.isHidden = false
                        self.addChild(self.playerNode!)
                        sprite.removeFromParent()
                    }
                }
            }
        }
        
        tilemap.tileSet = SKTileSet(tileGroups: [])
        tilemap.removeFromParent()
        
        if (playerNode == nil) {
            fatalError("Player missing from map.")
        }
        
        self.camera = playerCamera
        self.playerCamera!.position = self.playerNode!.position
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.camera?.position != self.playerNode?.position {
            self.camera?.run(SKAction.move(to: self.playerNode?.position ?? CGPoint(x: 0, y: 0), duration: 1))
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        var delta = CGVector(dx: 0, dy: 0)
        switch Int(event.keyCode) {
        case kVK_ANSI_W, kVK_UpArrow:
            delta.dy = (self.unit?.width ?? 1) / 2
            self.playerNode?.move(delta)
        case kVK_ANSI_S, kVK_DownArrow:
            delta.dy = -1 * ((self.unit?.width ?? 1) / 2)
            self.playerNode?.move(delta)
        case kVK_ANSI_A, kVK_LeftArrow:
            delta.dx = -1 * ((self.unit?.width ?? 1) / 2)
            self.playerNode?.move(delta)
        case kVK_ANSI_D, kVK_RightArrow:
            delta.dx = (self.unit?.width ?? 1) / 2
            self.playerNode?.move(delta)
        case kVK_ANSI_F:
            let _ = self.playerNode?.nextCostume()
        default:
            break
        }
    }
}
