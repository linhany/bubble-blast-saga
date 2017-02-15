//
//  Scene.swift
//  GameEngine
//
//  Created by Yong Lin Han on 7/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// `Scene` represents a scene of content for the GameEngine.
/// Provides a general framework for a game to run.
/// When using, subclass this to implement specific game behavior and logic.
class Scene {

    /// The array of `gameObjects` associated with this `Scene`.
    internal var gameObjects: [GameObject]

    /// The `PhysicsWorld` that this `Scene` runs to handle `gameObjects` behavior.
    internal let physicsWorld: PhysicsWorld

    /// The `PhysicsBody` associated with this `Scene`, if any.
    internal var physicsBody: PhysicsBody?

    /// Notification Center to notify observers of game events.
    private let nc = NotificationCenter.default

    init() {
        gameObjects = []
        physicsWorld = PhysicsWorld()
    }

    /// Runs a single iteration of this `Scene`.
    /// Meant to be called in the `gameLoop` by the presenting view.
    func run() {
        update()
        simulatePhysics()
    }

    /// Adds a `gameObject` onto this `Scene`.
    func add(gameObject: GameObject) {
        gameObjects.append(gameObject)
    }

    /// Removes a `gameObject` from this `Scene`.
    /// Notifies observers of this removed `gameObject`.
    /// If the `gameObject` does not exist in this `Scene`, does nothing.
    func remove(gameObject: GameObject) {
        var indexToRemove: Int?
        for index in 0..<gameObjects.count {
            if gameObjects[index] === gameObject {
                indexToRemove = index
            }
        }
        guard let foundIndexToRemove = indexToRemove else {
            return
        }
        gameObjects.remove(at: foundIndexToRemove)
        // Remove its physics body from physics world, if it exists.
        gameObject.physicsBody = nil
        postNotification(name: Constants.notifyRemovedGameObject,
                         userInfo: [Constants.gameObjectIdentifier: gameObject])
    }

    /// Override to update the `Scene` with game specific behavior.
    func update() {
    }

    /// Override to respond to user touch, if needed.
    func handleTouch(at touchLocation: CGPoint) {
    }

    /// Simulate the `physicsWorld`.
    private func simulatePhysics() {
        physicsWorld.run()
    }

    func postNotification(name: String, userInfo: [String: Any]) {
        nc.post(name: Notification.Name(name),
                object: nil,
                userInfo: userInfo)
    }
}
