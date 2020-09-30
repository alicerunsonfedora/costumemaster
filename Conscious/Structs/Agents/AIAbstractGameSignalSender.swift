//
//  AIAbstractGameSignalSender.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//

import Foundation

struct AIAbstractGameSignalSender {
    var position: CGPoint
    var active: Bool
    var timer: Int = -1
    var outputs: [CGPoint]
}
