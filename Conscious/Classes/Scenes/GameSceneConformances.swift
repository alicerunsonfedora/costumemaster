//
//  GameSceneConformances.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 30/7/22.
//

import CranberrySprite
import SpriteKit

// MARK: Structural Object Generator Conformance

extension GameScene: GameSceneStructuralGenerator {
    func makePlayer(from data: CSTileMapDefinition, with configuration: LevelDataConfiguration?) -> Player? {
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

    func makeGameCenterTrigger(from data: CSTileMapDefinition, with configuration: LevelDataConfiguration?) -> GameAchievementTrigger? {
        let trigger = GameAchievementTrigger(
            with: configuration?.achievementTrigger, at: data.position
        )
        trigger.position = data.sprite.position
        trigger.size = data.sprite.size
        return trigger
    }

    func makeDeathPit(from data: CSTileMapDefinition, type: GameTileType) -> GameDeathPit? {
        let killer = GameDeathPit(color: .clear, size: data.sprite.size)
        killer.trigger = (type == .triggerKill)
        if type == .deathPit {
            killer.texture = data.sprite.texture
        }
        killer.zPosition = -999
        killer.position = data.sprite.position
        return killer
    }

    func makeDoor(from data: CSTileMapDefinition) -> DoorReceiver? {
        let receiver = DoorReceiver(
            fromInput: [],
            reverseSignal: false,
            baseTexture: "door",
            at: data.position
        )
        receiver.activationMethod = .anyInput
        receiver.position = data.sprite.position
        receiver.size = data.sprite.size
        return receiver
    }

    func makeLever(from data: CSTileMapDefinition) -> GameLever? {
        let lever = GameLever(at: data.position)
        lever.position = data.sprite.position
        lever.size = data.sprite.size
        return lever
    }

    func makeAlarmClock(from data: CSTileMapDefinition) -> GameAlarmClock? {
        let alarm = GameAlarmClock(
            with: configuration?.defaultTimerDelay ?? 3.0,
            at: data.position
        )
        alarm.position = data.sprite.position
        alarm.size = data.sprite.size
        return alarm
    }

    func makeComputer(from data: CSTileMapDefinition, type: GameTileType) -> GameComputer? {
        let computer = GameComputer(
            at: data.position,
            with: type == .computerT1
        )
        computer.position = data.sprite.position
        computer.size = data.sprite.size
        return computer
    }

    func makePressurePlate(from data: CSTileMapDefinition) -> GamePressurePlate? {
        let plate = GamePressurePlate(at: data.position)
        plate.position = data.sprite.position
        plate.size = data.sprite.size
        return plate
    }

    func makeBiometrics(from data: CSTileMapDefinition) -> GameIrisScanner? {
        let iris = GameIrisScanner(at: data.position)
        iris.position = data.sprite.position
        iris.size = data.sprite.size
        return iris
    }

    func makeHeavyObject(from data: CSTileMapDefinition) -> GameHeavyObject? {
        let object = GameHeavyObject(
            with: data.skDefinition.name?.replacingOccurrences(of: "floor_ho_", with: "") ?? "cabinet",
            at: data.position
        )
        object.position = data.sprite.position
        object.zPosition = playerNode?.zPosition ?? 5
        object.size = data.sprite.size
        return object
    }

    func makeWall(from data: CSTileMapDefinition) -> GameStructureObject? {
        guard let wallName = data.skDefinition.name else { return nil }
        let wallTexture = wallName.starts(with: "wall_edge") ? "wall_edge_physics_mask" : wallName
        let wall = GameStructureObject(with: data.sprite.texture, size: data.sprite.size)
        if wallName.contains("passable") {
            wall.locked = false
        }
        wall.position = data.sprite.position
        wall.instantiateBody(with: getWallPhysicsBody(with: wallTexture))
        wall.name = "wall_\(data.position.x)_\(data.position.y)\(wallName.starts(with: "wall_edge") ? "_edge" : ""))"
        wall.worldPosition = data.position

        if wallName.contains("dbroken"), let sparks = SKEmitterNode(fileNamed: "ElectricalSpark") {
            sparks.zPosition = 100
            sparks.position = CGPoint(x: wall.position.x + 40, y: wall.position.y - 16)
            addChild(sparks)
        }
        return wall
    }
}

// MARK: - Game World Conformance

extension GameScene: CSWorldCreateable {
    func applyOnTile(from definition: CranberrySprite.CSTileMapDefinition) {
        // Offset by one to prevent texture collisions.
        definition.sprite.size = CGSize(width: definition.unitSize.width + 1, height: definition.unitSize.height + 1)

        let type = getTileType(fromDefinition: definition.skDefinition)

        switch type {
        case .wall:
            guard let wall = makeWall(from: definition) else { return }
            structure.addChild(wall)

        case .player:
            playerNode = makePlayer(from: definition, with: configuration)
            addChild(playerNode!)
            definition.sprite.texture = SKTexture(imageNamed: "floor")
            definition.sprite.zPosition = -999
            addChild(definition.sprite)

        case .triggerGameCenter:
            guard let trigger = makeGameCenterTrigger(from: definition, with: configuration) else {
                return
            }
            switches.append(trigger)

        case .deathPit, .triggerKill:
            guard let killer = makeDeathPit(from: definition, type: type) else {
                return
            }
            structure.addChild(killer)

        case .floor:
            definition.sprite.zPosition = -999
            structure.addChild(definition.sprite)

        case .door:
            guard let receiver = makeDoor(from: definition) else { return }
            receiver.playerListener = playerNode
            receivers.append(receiver)

        case .lever:
            guard let lever = makeLever(from: definition) else { return }
            switches.append(lever)

        case .alarmClock:
            guard let alarm = makeAlarmClock(from: definition) else { return }
            switches.append(alarm)

        case .computerT1, .computerT2:
            guard let computer = makeComputer(from: definition, type: type) else { return }
            switches.append(computer)

        case .pressurePlate:
            guard let plate = makePressurePlate(from: definition) else { return }
            switches.append(plate)

        case .biometricScanner:
            guard let iris = makeBiometrics(from: definition) else { return }
            switches.append(iris)

        case .heavyObject:
            guard let object = makeHeavyObject(from: definition) else { return }
            interactables.append(object)
            definition.sprite.texture = SKTexture(imageNamed: "floor")
            definition.sprite.zPosition = -999
            addChild(definition.sprite)
        default:
            break
        }
    }

    func generateWorld() {
        guard let world = world as? SKTileMapNode else { return }
        let mapUnit = world.tileSize; unit = mapUnit
        world.parseTilemap(applicator: applyOnTile)

        for node in switches { node.zPosition -= 5; addChild(node) }
        for node in receivers { node.zPosition -= 5; addChild(node) }
        for node in interactables { addChild(node) }

        for node in receivers where node.worldPosition == configuration?.exitLocation {
            if let door = node as? DoorReceiver { self.exitNode = door }
        }

        // Delete the tilemap from memory.
        world.tileSet = SKTileSet(tileGroups: [])
        world.removeFromParent()

        // Finally, clump all of the non-player sprites under the structure node to prevent scene
        // overbearing.
        structure.zPosition = -5
        addChild(structure)
    }
}
