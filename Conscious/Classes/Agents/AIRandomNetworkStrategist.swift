//
//  AIRandomNetworkStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/9/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

// TODO: Implement the random network distillation strategist.

class AIRandomNetworkStrategist: GKStrategist {
    var gameModel: GKGameModel?

    var randomSource: GKRandom?

    func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        return nil
    }

    func isEqual(_ object: Any?) -> Bool {
        return false
    }

    var hash: Int = 0

    var superclass: AnyClass?

    func `self`() -> Self {
        return self
    }

    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func isProxy() -> Bool {
        return false
    }

    func isKind(of aClass: AnyClass) -> Bool {
        return false
    }

    func isMember(of aClass: AnyClass) -> Bool {
        return false
    }

    func conforms(to aProtocol: Protocol) -> Bool {
        return false
    }

    func responds(to aSelector: Selector!) -> Bool {
        return false
    }

    var description: String = ""

}
