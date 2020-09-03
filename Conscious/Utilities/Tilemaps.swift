//
//  Tilemaps.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/2/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

extension SKTileMapNode {
    /// Iterate through the tilemap and apply a function to each tile.
    /// - Note: This method will skip tiles with no definitions (empty tiles).
    /// - Parameter handler: The function that will be applied on every tile.
    func parse(handler: ((TilemapParseData) -> Void)) {
        let mapUnit = self.tileSize
        let unit = mapUnit
        let mapHalfWidth = CGFloat(self.numberOfColumns) / (mapUnit.width * 2)
        let mapHalfHeight = CGFloat(self.numberOfRows) / (mapUnit.height * 2)
        let origin = self.position

        for col in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                if let defined = self.tileDefinition(atColumn: col, row: row) {
                    let texture = defined.textures[0]
                    let spriteX = CGFloat(col) * mapUnit.width - mapHalfWidth + (mapUnit.width / 2)
                    let spriteY = CGFloat(row) * mapUnit.height - mapHalfHeight + (mapUnit.height / 2)

                    // Change the texure's filtering method to allow pixelation.
                    texture.filteringMode = .nearest
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.position = CGPoint(x: spriteX + origin.x, y: spriteY + origin.y)
                    sprite.zPosition = 1
                    sprite.isHidden = false
                    handler(
                        TilemapParseData(
                            definition: defined,
                            column: col,
                            row: row,
                            unit: unit,
                            sprite: sprite,
                            texture: texture
                        )
                    )
                }
            }
        }

    }
}
