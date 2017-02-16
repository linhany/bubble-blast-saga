//
//  PhysicsWorld.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

// MARK: - PhysicsContactDelegate protocol.
/// The `PhysicsContactDelegate` handles collisions 
/// when physics bodies come into contact.
protocol PhysicsContactDelegate {
    /// Handle collisions between physics bodies.
    func handleCollisions(_ collisions: [Collision])
}

// MARK: - PhysicsWorld
/// The `PhysicsWorld` is the core of PhysicsEngine.
/// It simulates a physics space where physics bodies interact.
/// It is heavily simplified to only account for simple object movement
/// and collision detection between specific-shaped physics bodies, 
/// but can be easily extended if necessary.
class PhysicsWorld {

    /// The array of `PhysicsBody`s that are in this `PhysicsWorld`.
    static private var physicsBodies: [PhysicsBody] = []

    /// The PhysicsContactDelegate that handles collisions.
    internal var contactDelegate: PhysicsContactDelegate?

    /// The array that tracks `Collision`s occuring.
    private var collisions: [Collision] = []

    /// Adds the `physicsBody` into this `PhysicsWorld`.
    /// Static to enable an individual `PhysicsBody` to add itself in upon
    /// initialisation.
    static func add(physicsBody: PhysicsBody) {
        physicsBodies.append(physicsBody)
    }

    /// Removes the `physicsBody` from this `PhysicsWorld`.
    /// If `physicsBody` does not exist, does nothing.
    static func remove(physicsBody: PhysicsBody) {
        var indexToRemove: Int?
        for index in 0..<physicsBodies.count {
            if physicsBodies[index] === physicsBody {
                indexToRemove = index
                break
            }
        }
        guard let foundIndexToRemove = indexToRemove else {
            return
        }
        physicsBodies.remove(at: foundIndexToRemove)
    }

    static func reset() {
        for physicsBody in physicsBodies {
            remove(physicsBody: physicsBody)
        }
        physicsBodies.removeAll()
    }

    /// Advances the `PhysicsWorld`.
    func run() {
        updatePhysicsBodies()
        detectCollisions()
        resolveCollisions()
    }

    /// Handles simple object movement by updating their physics bodies
    /// to be at their new respective positions.
    private func updatePhysicsBodies() {
        for physicsBody in PhysicsWorld.physicsBodies {
            if physicsBody.isResting {
                continue
            }
            handleSimpleMovement(for: physicsBody)
        }
    }

    /// Handles simple object movement by updating `physicsBody`
    /// to be at its new position, based on its `velocity`.
    /// It is recommended that this `velocity` is kept low, since
    /// current implementation will only do collision detection after 
    /// increasing it by its displacement.
    /// This is to prevent a fast moving `physicsBody` from passing through
    /// another `physicsBody` without detecting collision in time.
    private func handleSimpleMovement(for physicsBody: PhysicsBody) {
        guard let position = physicsBody.position else {
            return
        }
        let velocity = physicsBody.velocity
        let newX = position.x + velocity.dx
        let newY = position.y + velocity.dy
        physicsBody.position = CGPoint(x: newX, y: newY)
    }

    /// Detect collisions between two physics bodies, if at least
    /// one of them is moving.
    /// Current implementation does not support collisions 
    /// between two stationary physics bodies.
    private func detectCollisions() {
        for physicsBody in PhysicsWorld.physicsBodies {
            if physicsBody.isResting {
                continue
            }
            doCollisionTestsOn(physicsBody)
        }
    }

    /// Calls the `PhysicsContactDelegate` to handle collisions detected.
    private func resolveCollisions() {
        guard let contactDelegate = contactDelegate else {
            assertionFailure("Contact delegate not set up!")
            return
        }
        contactDelegate.handleCollisions(collisions)
        collisions.removeAll()
    }

    /// Does a collision test on a `physicsBody` with all the other
    /// `physicsBody`s in the `PhysicsWorld`.
    /// Current implementation only supports moving `Circle` physicsBody,
    /// and stationary `Circle` and `EdgeLoop` `physicsBody`s.
    private func doCollisionTestsOn(_ physicsBody: PhysicsBody) {
        for otherPhysicsBody in PhysicsWorld.physicsBodies {
            // Avoid doing collision test with itself.
            guard otherPhysicsBody !== physicsBody else {
                continue
            }
            doCollisionTestOn(physicsBody, with: otherPhysicsBody)
        }
    }

    /// Does a collision test on a `physicsBody` with all the other
    /// `physicsBody`s in the `PhysicsWorld`.
    /// Current implementation only supports `Circle` physicsBody,
    /// and `Circle` and `EdgeLoop` `otherPhysicsBody`.
    private func doCollisionTestOn(_ physicsBody: PhysicsBody, with otherPhysicsBody: PhysicsBody) {
        guard let physicsBodyType = physicsBody.physicsBodyType as? Circle else {
            assertionFailure("Non-circle physicsBody is currently unsupported.")
            return
        }
        if let otherPhysicsBodyType = otherPhysicsBody.physicsBodyType as? Circle {
            collisionTest(circle: physicsBodyType, withCircle: otherPhysicsBodyType)
        } else if let otherPhysicsBodyType = otherPhysicsBody.physicsBodyType as? EdgeLoop {
            collisionTest(circle: physicsBodyType, withEdgeLoop: otherPhysicsBodyType)
        } else {
            assertionFailure("Currently only supports Circle and EdgeLoop otherPhysicsBody.")
        }
    }

    /// Circle with circle collision test.
    /// As `PhysicsBodyType`s, both `circle`s in this test should have an
    /// associated `physicsBody`.
    private func collisionTest(circle: Circle, withCircle otherCircle: Circle) {
        guard let circlePhysicsBody = circle.physicsBody,
              let otherCirclePhysicsBody = otherCircle.physicsBody else {
            assertionFailure("Must have physics bodies associated!")
            return
        }
        let dx = circle.center.x - otherCircle.center.x
        let dy = circle.center.y - otherCircle.center.y
        let distance = sqrt(dx*dx + dy*dy)
        if distance <= circle.radius + otherCircle.radius {
            let collision =
                Collision(circlePhysicsBody,
                          with: otherCirclePhysicsBody,
                          collisionType: .circleWithCircle)
            collisions.append(collision)
        }
    }

    /// Circle with edge loop collision test.
    /// As `PhysicsBodyType`s, both `circle` and `edgeLoop` in this test should have an
    /// associated `physicsBody`.
    private func collisionTest(circle: Circle, withEdgeLoop edgeLoop: EdgeLoop) {
        guard let circlePhysicsBody = circle.physicsBody,
              let edgeLoopPhysicsBody = edgeLoop.physicsBody else {
            assertionFailure("Must have physics bodies associated!")
            return
        }

        // Conditions for collision.
        let hasCollisionWithRightSideOfEdgeLoop =
            circle.center.x + circle.radius > edgeLoop.size.width - edgeLoop.origin.x
        let hasCollisionWithLeftSideOfEdgeLoop =
            circle.center.x - circle.radius <= edgeLoop.origin.x
        let hasCollisionWithBottomSideOfEdgeLoop =
            circle.center.y + circle.radius > edgeLoop.size.height - edgeLoop.origin.y
        let hasCollisionWithTopSideOfEdgeLoop =
            circle.center.y - circle.radius <= edgeLoop.origin.y

        // Assign the right collision type.
        var collisionType: CollisionType?
        if hasCollisionWithRightSideOfEdgeLoop {
            collisionType = .circleWithRightOfEdgeLoop
        } else if hasCollisionWithLeftSideOfEdgeLoop {
            collisionType = .circleWithLeftOfEdgeLoop
        } else if hasCollisionWithBottomSideOfEdgeLoop {
            collisionType = .circleWithBottomOfEdgeLoop
        } else if hasCollisionWithTopSideOfEdgeLoop {
            collisionType = .circleWithTopOfEdgeLoop
        }

        // If collisionType is not nil, collision is detected.
        if let collisionType = collisionType {
            let collision =
                Collision(circlePhysicsBody,
                          with: edgeLoopPhysicsBody,
                          collisionType: collisionType)
            collisions.append(collision)
        }
    }

}
