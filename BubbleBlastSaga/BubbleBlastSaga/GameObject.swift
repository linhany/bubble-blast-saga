//
//  GameObject.swift
//  GameEngine
//
//  Created by Yong Lin Han on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit
import PhysicsEngine

/// The `GameObject` class is the basic game entity recognized by the GameEngine.
/// Subclass this to use custom classes as game entities.
class GameObject: NSObject, PhysicsBodyOwner {

    /// The String which identifies the image associated with this `GameObject`, if any.
    internal var imageString: String?

    /// The size of the `GameObject` when rendered on the view.
    internal var size: CGSize?

    /// The position of this `GameObject` with regards to the view it is on.
    private var _position: CGPoint?

    /// The `PhysicsBody` associated with this `GameObject`, if any.
    private var _physicsBody: PhysicsBody?

    /// Notification Center to notify observers when this `GameObject` is moving.
    private let nc = NotificationCenter.default

    // MARK: - PhysicsBodyOwner protocol
    internal var position: CGPoint? {
        get {
            return _position
        }
        set(newPosition) {
            _position = newPosition
            // Notify observers when this `GameObject` is set to a new position.
            nc.post(name: Notification.Name(Constants.notifyMovingGameObject),
                    object: nil,
                    userInfo: [Constants.gameObjectIdentifier: self])
        }
    }

    internal var physicsBody: PhysicsBody? {
        get {
            return _physicsBody
        }
        set(newPhysicsBody) {
            guard let newPhysicsBody = newPhysicsBody else {
                // Remove existing physics body when nil is passed in, if any.
                if let physicsBody = _physicsBody {
                    PhysicsWorld.remove(physicsBody: physicsBody)
                }
                _physicsBody = nil
                return
            }
            _physicsBody = newPhysicsBody
            _physicsBody?.physicsBodyOwner = self
        }
    }

}
