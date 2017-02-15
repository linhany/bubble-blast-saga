//
//  PhysicsBodyOwner.swift
//  GameEngine
//
//  Created by Yong Lin Han on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The protocol that `GameObject`s must conform to have a `PhysicsBody`.
/// Separates `PhysicsBody` from having to know about `GameObject`.
protocol PhysicsBodyOwner {
    /// The position of the `PhysicsBodyOwner` will be used as
    /// the position for this `PhysicsBody`.
    var position: CGPoint? {
        get set
    }
    /// The `PhysicsBodyOwner` must have a reference to this `PhysicsBody`.
    var physicsBody: PhysicsBody? {
        get set
    }
}
