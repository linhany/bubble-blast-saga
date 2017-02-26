//
//  PhysicsBodyType.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// The abstract class representing different possible `PhysicsBodyType`s.
public class PhysicsBodyType {
    /// The `physicsBody` that has this particular `PhysicsBodyType`.
    public weak var physicsBody: PhysicsBody?
}
