//
//  GameLevelScene.swift
//  GameEngine
//
//  Created by Yong Lin Han on 8/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//  Credits: https://www.raywenderlich.com/145318/spritekit-swift-3-tutorial-beginners

import UIKit

/// A game specific `scene` for our Bubble Game.
/// Contains the `GameBubble`s in this `scene`.
/// This class is concerned with what is going on in the `scene`,
/// but does not contain the actual algorithms and state of the game grid.
/// After setting up the initial `scene`, acts as the delegate
/// for `GameLogic` and `PhysicsWorld` to update the `scene`.
class GameLevelScene: Scene, PhysicsContactDelegate, GameLogicDelegate {

    /// The ViewController for the view this scene is rendered on.
    /// Uses it to set `GameObject` positions.
    private let gameViewController: GameViewController

    /// The `GameLogic` for our Bubble Game.
    private let gameLogic: GameLogic

    /// The Queue of `GameBubble`s for the player to shoot.
    private var projectileQueue = Queue<GameBubble>()

    /// The Boolean that returns true if the projectile is ready to be fired.
    private var isReadyToFire: Bool = true

    /// The newly snapped bubble in the grid.
    private var newlySnappedBubble: GameBubble?

    /// Since our game currently only allows one projectile in the game at any
    /// one time, we keep reference to it and only let the user fire after it has
    /// been snapped into the grid.
    private var currentProjectile: GameBubble?

    init(modelManager: ModelManager,
         gameViewController: GameViewController,
         gameProjectileQueue: Queue<GameBubble>) {
        self.gameLogic = GameLogic(modelManager: modelManager,
                                   gameViewController: gameViewController)
        self.gameViewController = gameViewController
        self.projectileQueue = gameProjectileQueue
        super.init()
        physicsBody = PhysicsBody(edgeLoopFrom: gameViewController.view.frame)
        physicsWorld.contactDelegate = self
        gameLogic.delegate = self
        prepareToFire()
    }

    override func update() {
        // Skip updating unless there is a newly snapped bubble in the grid.
        guard let newBubble = newlySnappedBubble else {
            return
        }
        gameLogic.handleNewlySnappedBubble(newBubble)
        newlySnappedBubble = nil
        prepareToFire()
    }

    override func handleTouch(at touchLocation: CGPoint) {
        guard isReadyToFire && isWithinFiringAngleRange(touchLocation) else {
            return
        }
        guard let gameProjectile = currentProjectile else {
            assertionFailure("Projectile was not set up!")
            return
        }
        isReadyToFire = false
        gameViewController.animateCannonFire()
        let radius = gameViewController.getBubbleRadius()
        let physicsBodyRadius =
            radius * CGFloat(Constants.gameBubbleCollisionAdjustedPercentage)
        gameProjectile.physicsBody = PhysicsBody(circleOfRadius: physicsBodyRadius)

        // Get the direction of where to shoot
        let offset = touchLocation - gameViewController.getCannonPosition()
        let direction = offset.normalized()
        gameProjectile.physicsBody?.velocity = CGVector(dx: direction.x,
                                                        dy: direction.y)
    }

    // MARK - PhysicsContactDelegate Protocol

    func handleCollisions(_ collisions: [Collision]) {
        for collision in collisions {
            handleCollision(collision)
        }
    }

    // MARK - GameLogicDelegate Protocol

    func removeGameBubbleFromScene(_ gameBubble: GameBubble) {
        remove(gameObject: gameBubble)
    }

    func initialiseGame(gridState: [[GameBubble?]]) {
        for row in 0..<gridState.count {
            for col in 0..<gridState[row].count {
                guard let gameBubble = gridState[row][col] else {
                    continue
                }
                add(gameObject: gameBubble)
                let width = gameViewController.getBubbleWidth()
                let radius = gameViewController.getBubbleRadius()
                gameBubble.position = gameViewController.getBubblePosition(row: row, col: col)
                gameBubble.size = CGSize(width: width, height: width)
                gameBubble.physicsBody = PhysicsBody(circleOfRadius: radius)
            }
        }

    }

    // MARK - Private helper functions

    /// Prepares to fire by adding the projectile from projectileQueue
    /// as a gameObject, initialising its attributes.
    private func prepareToFire() {
        isReadyToFire = true
        guard let projectile = try? projectileQueue.dequeue() else {
            assertionFailure("Queue cannot be empty! Game should be over.")
            return
        }
        add(gameObject: projectile)
        projectile.position = gameViewController.getCannonPosition()
        let bubbleWidth = gameViewController.getBubbleWidth()
        projectile.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        currentProjectile = projectile
    }

    private func handleCollision(_ collision: Collision) {
        let physicsBody = collision.physicsBody
        guard let projectile = physicsBody.physicsBodyOwner as? GameBubble,
                  projectile === currentProjectile else {
            return
        }
        handleCollision(projectile: projectile,
                        collisionType: collision.collisionType)
    }

    private func handleCollision(projectile: GameBubble, collisionType: CollisionType) {
        switch collisionType {
        case .circleWithCircle: snapToClosestGridCell(projectile)
        case .circleWithTopOfEdgeLoop: snapToClosestGridCell(projectile)
        case .circleWithLeftOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithRightOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithBottomOfEdgeLoop: dropOutFromBottom(projectile)
        }
    }

    /// Bounces the projectile off wall by multiplying its horizontal velocity (dx)
    /// by `reverseDirectionMultiplier`.
    private func bounceProjectileOffWall(_ projectile: GameBubble) {
        guard let physicsBody = projectile.physicsBody else {
            assertionFailure("Must have physics body")
            return
        }
        let currentVelocity = physicsBody.velocity

        physicsBody.velocity =
            CGVector(dx: currentVelocity.dx * CGFloat(Constants.reverseDirectionMultiplier),
                     dy: currentVelocity.dy)
    }

    /// Snaps the `projectile` to the closest grid cell.
    private func snapToClosestGridCell(_ projectile: GameBubble) {
        guard let position = projectile.position,
              let diameter = projectile.size?.width else {
                assertionFailure("Projectile not set up properly!")
                return
        }

        let radius = diameter/2
        // Account for offsets where bubble is in the front or end of an odd row.
        let possiblePositionsToSnap = [(position.x, position.y),
                                       (position.x + radius, position.y),
                                       (position.x - radius, position.y)]
        for (x, y) in possiblePositionsToSnap {
            if let (row, col) =
                gameViewController.getBubbleGridRowAndCol(position: CGPoint(x: x, y: y)) {
                snapToGrid(projectile, row: row, col: col)
                return
            }
        }
        // Closest grid cell is not found, that means that the user is trying to append
        // to a GameBubble in the last row of our grid.
        // PS5: Game over screen. Currently game continues on.
        remove(gameObject: projectile)
        prepareToFire()
    }

    /// Snaps the `gameBubble` to the grid position indicated by `row` and `col`.
    private func snapToGrid(_ gameBubble: GameBubble, row: Int, col: Int) {
        gameBubble.position = gameViewController.getBubblePosition(row: row, col: col)
        gameBubble.physicsBody?.isResting = true
        gameLogic.addToBubbleGridModel(gameBubble: gameBubble)
        newlySnappedBubble = gameBubble
        postNotification(name: Constants.notifyNewlySnappedGameBubble,
                         userInfo: ["GameBubble": gameBubble])
    }

    /// Drops out the `gameBubble` from bottom of grid.
    /// Currently this should never be called.
    private func dropOutFromBottom(_ gameBubble: GameBubble) {
        assertionFailure("Should never be called.")
        remove(gameObject: gameBubble)
        prepareToFire()
    }

    /// Returns true if the `touchLocation` is within the firing angle range.
    private func isWithinFiringAngleRange(_ touchLocation: CGPoint) -> Bool {
        let offset = touchLocation - gameViewController.getCannonPosition()
        let angle = Double(atan2(offset.x, -offset.y))

        return angle > Constants.leftFireAngleBound &&
               angle < Constants.rightFireAngleBound
    }

}
