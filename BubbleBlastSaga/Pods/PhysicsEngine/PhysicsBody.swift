//
//  PhysicsBody.swift
//  GameEngine
//
//  Created by Yong Lin Han on 8/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The `PhysicsBody` is the physics entity of PhysicsEngine.
public class PhysicsBody {

    /// The owner of this `PhysicsBody`.
    public var physicsBodyOwner: PhysicsBodyOwner?

    /// The `PhysicsBodyType` this `PhysicsBody` takes on.
    public var physicsBodyType: PhysicsBodyType

    /// The CGVector representing `velocity` of this `PhysicsBody`.
    public var velocity = CGVector(dx: 0.0, dy: 0.0)

    /// The `position` of this `PhysicsBody`.
    public var position: CGPoint? {
        get {
            return physicsBodyOwner?.position
        }
        set(newPosition) {
            physicsBodyOwner?.position = newPosition
        }
    }

    /// Returns true if this `PhysicsBody` is not moving.
    public var isResting: Bool {
        get {
            return velocity.dx == 0.0 && velocity.dy == 0.0
        }
        set(isNowResting) {
            if isNowResting {
                velocity = CGVector(dx: 0.0, dy: 0.0)
            }
        }
    }

    /// Creates a circular `PhysicsBody` centered on owning `PhysicsBody`'s `position`.
    public init(circleOfRadius radius: CGFloat) {
        physicsBodyType = Circle(radius: radius)
        physicsBodyType.physicsBody = self
        PhysicsWorld.add(physicsBody: self)
    }

    /// Creates an `edgeLoop` from a rectangle.
    public init(edgeLoopFrom rect: CGRect) {
        physicsBodyType = EdgeLoop(size: rect.size, origin: rect.origin)
        physicsBodyType.physicsBody = self
        PhysicsWorld.add(physicsBody: self)
    }
}
