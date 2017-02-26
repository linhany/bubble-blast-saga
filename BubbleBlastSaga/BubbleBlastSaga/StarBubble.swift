//
//  StarBubble.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// A star bubble will activate all types of the activator bubble.
class StarBubble: GameBubble {
    override var type: BubbleType {
        return .star
    }

    override func assignImageString() {
        imageString = Constants.starBubbleIdentifier
    }

    override func score() -> Int {
        return Constants.starBubbleScore
    }
}
