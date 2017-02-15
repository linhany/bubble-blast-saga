//
//  IndestructibleBubble.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

class IndestructibleBubble: GameBubble {
    override var type: BubbleType {
        return .indestructible
    }

    override func assignImageString() {
        imageString = Constants.indestructibleBubbleIdentifier
    }
}
