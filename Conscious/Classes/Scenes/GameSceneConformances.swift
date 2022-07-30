//
//  GameSceneConformances.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 30/7/22.
//

import SpriteKit
import GBMKUtils

// MARK: Structural Object Generator Conformance
extension GameScene: GameSceneStructuralGenerator {
    func makePlayer(from data: GBMKTilemapParseData, with configuration: LevelDataConfiguration?) -> Player? {
        let playerNode = Player(
            texture: data.texture,
            allowCostumes: Player.getCostumeSet(id: configuration?.costumeID ?? 0),
            startingWith: configuration?.startWithCostume ?? .flashDrive
        )
        playerNode.position = data.sprite.position
        playerNode.size = data.sprite.size
        if let disallow = configuration?.disallowCostume {
            playerNode.remove(costume: disallow)
        }
        return playerNode
    }

    func makeGameCenterTrigger(from data: GBMKTilemapParseData, with configuration: LevelDataConfiguration?) -> GameAchievementTrigger? {
        let trigger = GameAchievementTrigger(
            with: configuration?.achievementTrigger, at: CGPoint(x: data.column, y: data.row)
        )
        trigger.position = data.sprite.position
        trigger.size = data.sprite.size
        return trigger
    }

    func makeDeathPit(from data: GBMKTilemapParseData, type: GameTileType) -> GameDeathPit? {
        let killer = GameDeathPit(color: .clear, size: data.sprite.size)
        killer.trigger = (type == .triggerKill)
        if type == .deathPit {
            killer.texture = data.sprite.texture
        }
        killer.zPosition = -999
        killer.position = data.sprite.position
        return killer
    }

    func makeDoor(from data: GBMKTilemapParseData) -> DoorReceiver? {
        let receiver = DoorReceiver(
            fromInput: [],
            reverseSignal: false,
            baseTexture: "door",
            at: CGPoint(x: data.column, y: data.row)
        )
        receiver.activationMethod = .anyInput
        receiver.position = data.sprite.position
        receiver.size = data.sprite.size
        return receiver
    }

    func makeLever(from data: GBMKTilemapParseData) -> GameLever? {
        let lever = GameLever(at: CGPoint(x: data.column, y: data.row))
        lever.position = data.sprite.position
        lever.size = data.sprite.size
        return lever
    }

    func makeAlarmClock(from data: GBMKTilemapParseData) -> GameAlarmClock? {
        let alarm = GameAlarmClock(
            with: self.configuration?.defaultTimerDelay ?? 3.0,
            at: CGPoint(x: data.column, y: data.row)
        )
        alarm.position = data.sprite.position
        alarm.size = data.sprite.size
        return alarm
    }

    func makeComputer(from data: GBMKTilemapParseData, type: GameTileType) -> GameComputer? {
        let computer = GameComputer(
            at: CGPoint(x: data.column, y: data.row),
            with: type == .computerT1
        )
        computer.position = data.sprite.position
        computer.size = data.sprite.size
        return computer
    }

    func makePressurePlate(from data: GBMKTilemapParseData) -> GamePressurePlate? {
        let plate = GamePressurePlate(at: CGPoint(x: data.column, y: data.row))
        plate.position = data.sprite.position
        plate.size = data.sprite.size
        return plate
    }

    func makeBiometrics(from data: GBMKTilemapParseData) -> GameIrisScanner? {
        let iris = GameIrisScanner(at: CGPoint(x: data.column, y: data.row))
        iris.position = data.sprite.position
        iris.size = data.sprite.size
        return iris
    }

    func makeHeavyObject(from data: GBMKTilemapParseData) -> GameHeavyObject? {
        let object = GameHeavyObject(
            with: data.definition.name?.replacingOccurrences(of: "floor_ho_", with: "") ?? "cabinet",
            at: CGPoint(x: data.column, y: data.row)
        )
        object.position = data.sprite.position
        object.zPosition = self.playerNode?.zPosition ?? 5
        object.size = data.sprite.size
        return object
    }

    func makeWall(from data: GBMKTilemapParseData) -> GameStructureObject? {
        guard let wallName = data.definition.name else { return nil }
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
        return wall
    }
}
