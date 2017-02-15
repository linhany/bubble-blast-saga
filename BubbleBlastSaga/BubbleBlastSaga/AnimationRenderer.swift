//
//  AnimationRenderer.swift
//  GameEngine
//
//  Created by Yong Lin Han on 11/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Subclass of GameEngine's `Renderer` to add game specific bubble animation effects.
/// Creates custom animations for non-gameplay special effects using Swift libraries.
class AnimationRenderer: Renderer {

    private var newlySnappedGameBubbles: [GameBubble] = []
    private var disconnectedGameBubbles: [GameBubble] = []
    private var clusteredGameBubbles: [GameBubble] = []

    override init() {
        super.init()
        addObserverForNewlySnappedGameBubble()
        addObserverForRemoveDisconnectedGameBubble()
        addObserverForRemoveClusteredGameBubble()
    }

    override func moveImage(_ image: UIImageView, for gameObject: GameObject, on view: UIView) {
        guard let gameBubble = gameObject as? GameBubble else {
            super.moveImage(image, for: gameObject, on: view)
            return
        }
        moveImage(image, for: gameBubble, on: view)
    }

    override func removeImage(_ image: UIImageView, for gameObject: GameObject, on view: UIView) {
        guard let gameBubble = gameObject as? GameBubble else {
            super.removeImage(image, for: gameObject, on: view)
            return
        }
        removeImage(image, for: gameBubble, on: view)
    }

    override func untrackGameObjects() {
        newlySnappedGameBubbles.removeAll()
        disconnectedGameBubbles.removeAll()
        clusteredGameBubbles.removeAll()
        super.untrackGameObjects()
    }

    private func moveImage(_ image: UIImageView, for gameBubble: GameBubble, on view: UIView) {
        if newlySnappedGameBubbles.contains(gameBubble) {
            guard let position = gameBubble.position else {
                assertionFailure("Game bubble must have a position!")
                super.moveImage(image, for: gameBubble, on: view)
                return
            }
            animateBounce(gameBubbleImage: image, to: position, on: view)
        }
        super.moveImage(image, for: gameBubble, on: view)
    }

    private func removeImage(_ image: UIImageView, for gameBubble: GameBubble, on view: UIView) {
        if disconnectedGameBubbles.contains(gameBubble) {
            animateFall(gameBubbleImage: image, on: view)
        } else if clusteredGameBubbles.contains(gameBubble) {
            animateFade(gameBubbleImage: image)
        } else {
            super.removeImage(image, for: gameBubble, on: view)
        }
    }

    // MARK: - Custom Animations

    private func animateFall(gameBubbleImage: UIImageView, on view: UIView) {
        UIView.animate(
            withDuration: Constants.fallingBubbleAnimationDuration,
            animations: {
                gameBubbleImage.center.y += view.frame.size.height
        },
            completion: { _ in
                gameBubbleImage.removeFromSuperview()
        })
    }

    private func animateFade(gameBubbleImage: UIImageView) {
        UIView.perform(.delete, on: [gameBubbleImage], options: .curveEaseOut, animations: {
        }, completion: { _ in
            gameBubbleImage.removeFromSuperview()
        })
    }

    private func animateBounce(gameBubbleImage: UIImageView, to position: CGPoint, on view: UIView) {
        let snapBehavior = UISnapBehavior(item: gameBubbleImage, snapTo: position)
        let behavior = UIDynamicItemBehavior(items: [gameBubbleImage])
        let animator = UIDynamicAnimator(referenceView: view)
        snapBehavior.damping = 0.3
        behavior.elasticity = 1.4
        animator.addBehavior(snapBehavior)
        animator.addBehavior(behavior)
    }

    // MARK: - Notification helper functions

    private func addObserverForNewlySnappedGameBubble() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyNewlySnappedGameBubble),
            object: nil,
            queue: nil,
            using: updateNewlySnappedGameBubble)
    }

    private func addObserverForRemoveDisconnectedGameBubble() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyRemoveDisconnectedGameBubble),
            object: nil,
            queue: nil,
            using: updateRemoveDisconnectedGameBubble)
    }

    private func addObserverForRemoveClusteredGameBubble() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyRemoveClusteredGameBubble),
            object: nil,
            queue: nil,
            using: updateRemoveClusteredGameBubble)
    }

    private func updateNewlySnappedGameBubble(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let gameBubble = userInfo["GameBubble"]
                as? GameBubble else {
                    assertionFailure("Poster did not post it right.")
                    return
        }
        newlySnappedGameBubbles.append(gameBubble)
    }

    private func updateRemoveDisconnectedGameBubble(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let gameBubble = userInfo["GameBubble"]
                as? GameBubble else {
                    assertionFailure("Poster did not post it right.")
                    return
        }
        disconnectedGameBubbles.append(gameBubble)
    }

    private func updateRemoveClusteredGameBubble(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let gameBubble = userInfo["GameBubble"]
                as? GameBubble else {
                    assertionFailure("Poster did not post it right.")
                    return
        }
        clusteredGameBubbles.append(gameBubble)
    }
}
