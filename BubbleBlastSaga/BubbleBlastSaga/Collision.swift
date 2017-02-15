//
//  Collision.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// Represents a collision between physics bodies.
struct Collision {
    internal let physicsBody: PhysicsBody
    internal let otherPhysicsBody: PhysicsBody
    internal let collisionType: CollisionType

    /// Creates a Collision between `physicsBody` and `otherPhysicsBody`
    /// and stores the `collisionType`, to be handled by `PhysicsContactDelegate`.
    /// In the scenario of a player moved object colliding with another game object,
    /// the player moved object should always be stored first in the parameter
    /// `physicsBody` to allow for ease of retrieval.
    init(_ physicsBody: PhysicsBody,
         with otherPhysicsBody: PhysicsBody,
         collisionType: CollisionType) {
        self.physicsBody = physicsBody
        self.otherPhysicsBody = otherPhysicsBody
        self.collisionType = collisionType
    }
}
