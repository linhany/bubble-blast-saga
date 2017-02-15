//
//  Renderer.swift
//  GameEngine
//
//  Created by Yong Lin Han on 7/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// `Renderer` is responsible for drawing `GameObject`s on the `view`.
/// To be rendered, a `GameObject` should have an associated 
/// `imageString`, `position` and `size`.
class Renderer {

    /// Array to keep track of all game objects rendered, and their associated image view.
    private var gameObjectImages: [(GameObject, UIImageView)] = []

    /// Array to keep track of moving game objects, for rerendering.
    private var movingGameObjects: [GameObject] = []

    /// Array to keep track of removed game objects, to remove its associated image view.
    private var removedGameObjects: [GameObject] = []

    /// Notification center for moving and removed game objects.
    internal let nc = NotificationCenter.default

    init() {
        addObserverForMovingGameObjects()
        addObserverForRemovedGameObjects()
    }

    /// Override to provide custom moving animations.
    func moveImage(_ image: UIImageView, for gameObject: GameObject, on view: UIView) {
        guard let position = gameObject.position else {
            assertionFailure("Moving Game object must have a position!")
            return
        }
        image.center = position
    }

    /// Override to provide custom removal animations.
    func removeImage(_ image: UIImageView, for gameObject: GameObject, on view: UIView) {
        image.removeFromSuperview()
    }

    /// Override to guarantee that untracking is called at the right time.
    /// Call super() to ensure parent class untracks as well.
    func untrackGameObjects() {
        movingGameObjects.removeAll()
        removedGameObjects.removeAll()
    }

    /// Draws the `GameObject`s in `scene` on the `view`.
    /// Meant to be called only the first time the `scene` is rendered.
    /// Subsequently, redraw() should be called instead.
    func draw(scene: Scene, on view: UIView) {
        for gameObject in scene.gameObjects {
            drawGameObject(gameObject, on: view)
        }
    }

    /// Redraws `GameObject`s in `scene` that are:
    /// - Moving `GameObject`s (Including newly added ones).
    /// - Removed `GameObject`s.
    /// Untracks these objects by clearing their associated arrays.
    func redraw(scene: Scene, on view: UIView) {
        redrawMovingGameObjects(on: view)
        redrawRemovedGameObjects(on: view)
        untrackGameObjects()
    }

    /// Redraws moving `GameObject`s on `view`.
    private func redrawMovingGameObjects(on view: UIView) {
        for movingGameObject in movingGameObjects {
            redrawMovingGameObject(movingGameObject, on: view)
        }
    }

    /// Redraws `movingGameObject` on `view`.
    /// A newly added `GameObject` is also considered as moving as long as
    /// it has its `position` set. However, `imageString` and `size` of this new
    /// `GameObject` is also required before it can be rendered.
    private func redrawMovingGameObject(_ movingGameObject: GameObject, on view: UIView) {
        var isNewlyAdded = true
        for (gameObject, image) in gameObjectImages {
            // Compare by reference to find its associated image view.
            if gameObject === movingGameObject {
                isNewlyAdded = false
                moveImage(image, for: gameObject, on: view)
                break
            }
        }
        // Not currently rendered in scene, need to make new image view.
        if isNewlyAdded {
            drawGameObject(movingGameObject, on: view)
        }
    }

    /// Redraws removed `GameObject`s on `view`.
    private func redrawRemovedGameObjects(on view: UIView) {
        guard !removedGameObjects.isEmpty else {
            return
        }
        var index: Int?
        for removedGameObject in removedGameObjects {
            var count: Int = 0
            for (gameObject, image) in gameObjectImages {
                if gameObject === removedGameObject {
                    removeImage(image, for: gameObject, on: view)
                    index = count
                    break
                }
                count += 1
            }
        }
        guard let removedObjectIndex = index else {
            assertionFailure("Game object to remove should be currently in scene!")
            return
        }
        gameObjectImages.remove(at: removedObjectIndex)
    }

    /// Draws `gameObject` on the `view`.
    /// Currently only supports drawing of circle `gameObject`s since we set the `position`
    /// given to be the center of the image view.
    private func drawGameObject(_ gameObject: GameObject, on view: UIView) {
        guard let imageString = gameObject.imageString,
              let position = gameObject.position,
              let size = gameObject.size else {
            return
        }
        let image = UIImage(named: imageString)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        imageView.center = position
        view.insertSubview(imageView, at: 1)
        gameObjectImages.append(gameObject, imageView)
    }

    private func addObserverForMovingGameObjects() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyMovingGameObject),
            object: nil,
            queue: nil,
            using: updateMovingGameObject)
    }

    private func addObserverForRemovedGameObjects() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyRemovedGameObject),
            object: nil,
            queue: nil,
            using: updateRemovedGameObject)
    }

    private func updateMovingGameObject(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let gameObject = userInfo[Constants.gameObjectIdentifier]
                as? GameObject else {
                    assertionFailure("Poster did not post it right.")
                    return
        }
        movingGameObjects.append(gameObject)
    }

    private func updateRemovedGameObject(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let gameObject = userInfo[Constants.gameObjectIdentifier]
                as? GameObject else {
                    assertionFailure("Poster did not post it right.")
                    return
        }
        removedGameObjects.append(gameObject)
    }
}
