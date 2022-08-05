//
//  GameSceneStructuralGenerator.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 30/7/22.
//

import Foundation
import CranberrySprite

protocol GameSceneStructuralGenerator {

    func makeWall(from data: CSTileMapDefinition) -> GameStructureObject?
    func makePlayer(from data: CSTileMapDefinition, with configuration: LevelDataConfiguration?) -> Player?
    func makeGameCenterTrigger(from data: CSTileMapDefinition, with configuration:  LevelDataConfiguration?) -> GameAchievementTrigger?
    func makeDeathPit(from data: CSTileMapDefinition, type: GameTileType) -> GameDeathPit?
    func makeDoor(from data: CSTileMapDefinition) -> DoorReceiver?
    func makeLever(from data: CSTileMapDefinition) -> GameLever?
    func makeAlarmClock(from data: CSTileMapDefinition) -> GameAlarmClock?
    func makeComputer(from data: CSTileMapDefinition, type: GameTileType) -> GameComputer?
    func makePressurePlate(from data: CSTileMapDefinition) -> GamePressurePlate?
    func makeBiometrics(from data: CSTileMapDefinition) -> GameIrisScanner?
    func makeHeavyObject(from data: CSTileMapDefinition) -> GameHeavyObject?

}
