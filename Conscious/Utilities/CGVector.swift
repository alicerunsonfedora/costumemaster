//
//  CGVector.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/25/20.
//

import Foundation

extension CGVector {
    static func > (left: inout CGVector, right: CGVector) -> Bool {
        return left.dx > right.dx && left.dy > right.dy
    }
    static func < (left: inout CGVector, right: CGVector) -> Bool {
        return left.dx < right.dx && left.dy < right.dy
    }

}
