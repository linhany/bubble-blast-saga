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

    private let colorKeyString = "color"
    private let color: NormalBubbleColor

    init(color: NormalBubbleColor) {
        self.color = color
        super.init()
    }

    override func assignImageString() {
        switch color {
        case .red: imageString = Constants.redBubbleIdentifier
        case .orange: imageString = Constants.orangeBubbleIdentifier
        case .blue: imageString = Constants.blueBubbleIdentifier
        case .green: imageString = Constants.greenBubbleIdentifier
        case .purple: imageString = Constants.purpleBubbleIdentifier
        case .gray: imageString = Constants.grayBubbleIdentifier
        case .pink: imageString = Constants.pinkBubbleIdentifier
        }
    }

    override var type: BubbleType {
        switch color {
        case .red: return .normalRed
        case .orange: return .normalOrange
        case .blue: return .normalBlue
        case .green: return .normalGreen
        case .purple: return .normalPurple
        case .gray: return .normalGray
        case .pink: return .normalPink
        }
    }

    override func score() -> Int {
        return Constants.normalBubbleScore
    }

    override func encode(with aCoder: NSCoder) {
        // This tells the archiver how to encode the object
        aCoder.encode(color.rawValue, forKey: colorKeyString)
        super.encode(with: aCoder)
    }

    required init?(coder aDecoder: NSCoder) {
        // This tells the unarchiver how to decode the object
        let int = aDecoder.decodeInteger(forKey: colorKeyString)
        guard let colorToAssign = NormalBubbleColor(rawValue: int) else {
            return nil
        }
        color = colorToAssign
        super.init(coder: aDecoder)
    }

}
