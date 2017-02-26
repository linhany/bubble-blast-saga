//
//  IndestructibleBubble.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// An indestructible bubble cannot be destroyed by any bubble.
/// It can only be removed by falling out of the game screen.
class IndestructibleBubble: GameBubble {
    override var type: BubbleType {
        return .indestructible
    }

    override func assignImageString() {
        imageString = Constants.indestructibleBubbleIdentifier
    }

    override func score() -> Int {
        return Constants.indestructibleBubbleScore
    }
}
