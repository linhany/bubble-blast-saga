//
//  Level.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Represents a game level to be stored.
class Level: NSObject, NSCoding {
    private let fileNameKey = "FileNameKey"
    private let gridStateKey = "GridStateKey"
    private let preloadedKey = "PreloadedKey"
    internal let gridState: [[GameBubble?]]
    internal let fileName: String
    internal var isPreloaded = false

    init(gridState: [[GameBubble?]], fileName: String) {
        self.gridState = gridState
        self.fileName = fileName
    }

    func encode(with aCoder: NSCoder) {
        // This tells the archiver how to encode the object
        aCoder.encode(gridState, forKey: gridStateKey)
        aCoder.encode(fileName, forKey: fileNameKey)
        aCoder.encode(isPreloaded, forKey: preloadedKey)
    }

    required init?(coder aDecoder: NSCoder) {
        // This tells the unarchiver how to decode the object
        guard let gridState = aDecoder.decodeObject(forKey: gridStateKey) as? [[GameBubble?]],
              let fileName = aDecoder.decodeObject(forKey: fileNameKey) as? String else {
            return nil
        }
        let isPreloaded = aDecoder.decodeBool(forKey: preloadedKey)
        self.gridState = gridState
        self.fileName = fileName
        self.isPreloaded = isPreloaded
    }

}
