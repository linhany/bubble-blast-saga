//
//  RandomBubbleHelper.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 22/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Lazily generates random bubbles that are in the game grid.
class RandomBubbleHelper {

    private let bubbleTypeRawValueRange: (Int, Int)
    private var noOfBubbles: Int
    private let modelManager: ModelManager

    init(bubbleTypeRawValueRange: (Int, Int),
         noOfBubbles: Int,
         modelManager: ModelManager) {
        self.bubbleTypeRawValueRange = bubbleTypeRawValueRange
        self.noOfBubbles = noOfBubbles
        self.modelManager = modelManager
    }

    func nextBubble(isAccountingForBubblesGenerated: Bool) -> GameBubble? {
        if isAccountingForBubblesGenerated {
            noOfBubbles -= 1
            return noOfBubbles >= 0 ? randomizeNextBubbleInRange() : nil
        }
        return randomizeNextBubbleInRange()
    }

    /// Randomizes the next bubble in the bubbleTypeRawValueRange.
    /// Retries until the bubble obtained is present in the gridState of modelManager.
    private func randomizeNextBubbleInRange() -> GameBubble {
        let (start, end) = bubbleTypeRawValueRange
        var isGeneratedBubbleTypeInGrid = false
        var bubbleType: BubbleType?
        repeat {
            bubbleType = BubbleType(rawValue: getRandomNumber(from: start, to: end))
            guard let bubbleType = bubbleType else {
                fatalError("Random function implemented wrongly!")
            }
            isGeneratedBubbleTypeInGrid = modelManager.isBubbleTypeInGrid(bubbleType)
        } while !isGeneratedBubbleTypeInGrid

        guard let newBubbleType = bubbleType,
              let newBubble = modelManager.buildBubble(withBubbleType: newBubbleType) else {
            fatalError("Error with building bubble.")
        }
        return newBubble
    }

    /// Returns a random number between the range start to end, inclusive of to.
    private func getRandomNumber(from start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end-start+1))) + start
    }

}
