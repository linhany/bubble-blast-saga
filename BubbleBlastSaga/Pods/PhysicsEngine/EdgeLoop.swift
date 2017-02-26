//
//  EdgeLoop.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// An `edgeLoop` typically used to bound a game scene.
public class EdgeLoop: PhysicsBodyType {
    public var origin: CGPoint
    public var size: CGSize

    public init(size: CGSize, origin: CGPoint) {
        self.size = size
        self.origin = origin
    }
}
