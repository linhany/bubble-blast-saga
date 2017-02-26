//
//  BombBubble.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// A bomb bubble is a special bubble that explodes upon activation
/// and activates all its neighbors.
class BombBubble: GameBubble {
    override var type: BubbleType {
        return .bomb
    }

    override func assignImageString() {
        imageString = Constants.bombBubbleIdentifier
    }

    override func score() -> Int {
        return Constants.bombBubbleScore
    }
}
