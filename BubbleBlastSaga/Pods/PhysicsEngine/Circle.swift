//
//  Circle.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// A circular `PhysicsBodyType`.
public class Circle: PhysicsBodyType {
    /// The `center` of the circular body is the physicsBody's` position`.
    public var center: CGPoint {
        get {
            guard let center = physicsBody?.position else {
                fatalError("Physics body not set up properly!")
            }
            return center
        }
        set(newCenter) {
            physicsBody?.position = newCenter
        }
    }
    /// The `radius` of the circular body.
    public var radius: CGFloat

    public init(radius: CGFloat) {
        self.radius = radius
    }
}
