//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Abstract class for a game bubble.
/// Subclass this when adding more bubble types to the game.
/// Conforms to NSObject and NSCoding for object archiving.
class GameBubble: GameObject, NSCoding {

    /// The `BubbleType` of the `GameBubble`
    var type: BubbleType {
        fatalError("Must override this")
    }

    func assignImageString() {
        fatalError("Must override this")
    }

    func score() -> Int {
        fatalError("Must override this")
    }

    override init() {
        super.init()
        assignImageString()
    }

    func encode(with aCoder: NSCoder) {
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        assignImageString()
    }

}
