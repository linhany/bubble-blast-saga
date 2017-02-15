//
//  Circle.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// A circular `PhysicsBodyType`.
class Circle: PhysicsBodyType {
    /// The `center` of the circular body is the physicsBody's` position`.
    var center: CGPoint {
        guard let center = physicsBody?.position else {
            fatalError("Physics body not set up properly!")
        }
        return center
    }
    /// The `radius` of the circular body.
    var radius: CGFloat

    init(radius: CGFloat) {
        self.radius = radius
    }
}
