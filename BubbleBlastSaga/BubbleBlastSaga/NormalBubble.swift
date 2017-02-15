//
//  NormalBubble.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// A normal bubble that is colored.
/// A normal bubble is one that does not exhibit any special properties
/// other than dropping when in a group of three or more bubbles
/// of the same color.
class NormalBubble: GameBubble {

    private let color: NormalBubbleColor

    init(color: NormalBubbleColor) {
        self.color = color
        super.init()
    }

    override var type: BubbleType {
        switch color {
        case .red: return .normalRed
        case .orange: return .normalOrange
        case .blue: return .normalBlue
        case .green: return .normalGreen
        }
    }

    override func encode(with aCoder: NSCoder) {
        // This tells the archiver how to encode the object
        aCoder.encode(color.rawValue, forKey: Keys.Color.rawValue)
        super.encode(with: aCoder)
    }

    required init?(coder aDecoder: NSCoder) {
        // This tells the unarchiver how to decode the object
        let int = aDecoder.decodeInteger(forKey: Keys.Color.rawValue)
        guard let colorToAssign = NormalBubbleColor(rawValue: int) else {
            return nil
        }
        color = colorToAssign
        super.init(coder: aDecoder)
    }

    enum Keys: String {
        case Color = "color"
    }
}
