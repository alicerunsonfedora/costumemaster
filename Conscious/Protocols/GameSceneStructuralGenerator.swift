//
//  GameSceneStructuralGenerator.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 30/7/22.
//

import Foundation
import GBMKUtils

protocol GameSceneStructuralGenerator {

    func makeWall(from data: GBMKTilemapParseData) -> GameStructureObject?
    func makePlayer(from data: GBMKTilemapParseData, with configuration: LevelDataConfiguration?) -> Player?
    func makeGameCenterTrigger(from data: GBMKTilemapParseData, with configuration:  LevelDataConfiguration?) -> GameAchievementTrigger?
    func makeDeathPit(from data: GBMKTilemapParseData, type: GameTileType) -> GameDeathPit?
    func makeDoor(from data: GBMKTilemapParseData) -> DoorReceiver?
    func makeLever(from data: GBMKTilemapParseData) -> GameLever?
    func makeAlarmClock(from data: GBMKTilemapParseData) -> GameAlarmClock?
    func makeComputer(from data: GBMKTilemapParseData, type: GameTileType) -> GameComputer?
    func makePressurePlate(from data: GBMKTilemapParseData) -> GamePressurePlate?
    func makeBiometrics(from data: GBMKTilemapParseData) -> GameIrisScanner?
    func makeHeavyObject(from data: GBMKTilemapParseData) -> GameHeavyObject?

}
