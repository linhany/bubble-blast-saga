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

    /// The newly snapped bubbles in the grid.
    private var newlySnappedBubbles: [GameBubble] = []

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
        setUpProjectiles()
    }

    override func update() {
        // Skip updating unless there is a newly snapped bubble in the grid.
        if newlySnappedBubbles.isEmpty {
            return
        }
        for newBubble in newlySnappedBubbles {
            gameLogic.handleNewlySnappedBubble(newBubble)
        }
        newlySnappedBubbles.removeAll()
    }

    override func handleTouch(at touchLocation: CGPoint) {
        guard isWithinFiringAngleRange(touchLocation) else {
            return
        }
        guard let gameProjectile = getNextProjectile() else {
            assertionFailure("Projectile was not set up!")
            return
        }
        let radius = gameViewController.getBubbleRadius()
        let physicsBodyRadius =
            radius * CGFloat(Constants.gameBubbleCollisionAdjustedPercentage)
        gameProjectile.physicsBody = PhysicsBody(circleOfRadius: physicsBodyRadius)

        // Get the direction of where to shoot
        let offset = touchLocation - gameViewController.getCannonPosition()
        let direction = offset.normalized()
        gameProjectile.physicsBody?.velocity = CGVector(dx: direction.x,
                                                        dy: direction.y)
        gameViewController.animateCannonFire()
        showNextProjectiles()
    }

    // MARK: - Handling projectiles.

    func setUpProjectiles() {
        let nextProjectiles = getNextProjectilesInQueue()
        guard nextProjectiles.count == 2 else {
            assertionFailure("Should have 2 next projectiles.")
            return
        }
        let bubbleWidth = gameViewController.getBubbleWidth()
        let firstProjectile = nextProjectiles[0]
        add(gameObject: firstProjectile)
        firstProjectile.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        firstProjectile.position = gameViewController.getCannonPosition()

        let secondProjectile = nextProjectiles[1]
        add(gameObject: secondProjectile)
        secondProjectile.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        secondProjectile.position = gameViewController.getNextBubblePosition()
    }

    func getNextProjectile() -> GameBubble? {
        // which bubble colors are still in the grid?
        // what if there is only special bubbles left. game is over if theres only special bubbles left?.. YES?
        // how to show upcoming bubble?

        // dequeue the next projectile, show the peek().
        guard let projectileToFire = try? projectileQueue.dequeue() else {
            assertionFailure("Queue cannot be empty! Game should be over.")
            return nil
        }
        return projectileToFire
    }

    func showNextProjectiles() {
        let nextProjectiles = getNextProjectilesInQueue()
        if nextProjectiles.isEmpty {
            // game is over
            return
        }
        let firstProjectile = nextProjectiles[0]
        firstProjectile.position = gameViewController.getCannonPosition()
        postNotification(name: Constants.notifyLoadingCannonGameBubble,
                         userInfo: ["GameBubble": firstProjectile])
        if nextProjectiles.count == 2 {
            let nextProjectileToShow = nextProjectiles[1]
            let bubbleWidth = gameViewController.getBubbleWidth()
            // show next projectile as well.
            add(gameObject: nextProjectileToShow)
            nextProjectileToShow.position = gameViewController.getNextBubblePosition()
            nextProjectileToShow.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        }
    }

    /// Currently returns next 2 projectiles.
    func getNextProjectilesInQueue() -> [GameBubble] {
        var nextProjectiles: [GameBubble] = []
        let projectileArray = projectileQueue.toArray()
        if let firstProjectile = projectileArray.first {
            nextProjectiles.append(firstProjectile)
        }
        if projectileArray.count >= 2 {
            let secondProjectile = projectileArray[1]
            nextProjectiles.append(secondProjectile)
        }
        return nextProjectiles
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

    private func handleCollision(_ collision: Collision) {
        let physicsBody = collision.physicsBody
        let otherPhysicsBody = collision.otherPhysicsBody
        guard let projectile = physicsBody.physicsBodyOwner as? GameBubble,
            !physicsBody.isResting else {
            return
        }
        switch collision.collisionType {
        case .circleWithCircle: otherPhysicsBody.isResting
            ? snapToClosestGridCell(projectile) : bounceProjectilesOff(collision)
        case .circleWithTopOfEdgeLoop: snapToClosestGridCell(projectile)
        case .circleWithLeftOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithRightOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithBottomOfEdgeLoop: dropOutFromBottom(projectile)
        }
    }

    private func bounceProjectilesOff(_ collision: Collision) {
        let firstPhysicsBody = collision.physicsBody
        let secondPhysicsBody = collision.otherPhysicsBody
        guard let firstBubblePosition = firstPhysicsBody.position,
              let firstBubble = firstPhysicsBody.physicsBodyType as? Circle,
              let secondBubblePosition = secondPhysicsBody.position,
              let secondBubble = secondPhysicsBody.physicsBodyType as? Circle
              else {
            assertionFailure("Bubbles must be circles and have positions!")
            return
        }
        let firstBubbleRadius = firstBubble.radius
        let secondBubbleRadius = secondBubble.radius

        // Move away projectiles
        let midpoint = (firstBubblePosition + secondBubblePosition) / 2
        let firstBubbleNewPosition = midpoint +
            ((firstBubblePosition - secondBubblePosition).normalized()) * firstBubbleRadius
        let secondBubbleNewPosition = midpoint +
            ((secondBubblePosition - firstBubblePosition).normalized()) * secondBubbleRadius
        firstPhysicsBody.position = firstBubbleNewPosition
        secondPhysicsBody.position = secondBubbleNewPosition

        let normalized = (secondBubblePosition - firstBubblePosition).normalized()

        let p = firstPhysicsBody.velocity.dx * normalized.x +
            firstPhysicsBody.velocity.dy * normalized.y -
            secondPhysicsBody.velocity.dx * normalized.x -
            secondPhysicsBody.velocity.dy * normalized.y

        let firstBubbleNewVelocityX = firstPhysicsBody.velocity.dx - (p * normalized.x)
        let firstBubbleNewVelocityY = firstPhysicsBody.velocity.dy - (p * normalized.y)
        let secondBubbleNewVelocityX = secondPhysicsBody.velocity.dx + (p * normalized.x)
        let secondBubbleNewVelocityY = secondPhysicsBody.velocity.dy + (p * normalized.y)

        firstPhysicsBody.velocity =
            CGVector(dx: firstBubbleNewVelocityX, dy: firstBubbleNewVelocityY)
        secondPhysicsBody.velocity =
            CGVector(dx: secondBubbleNewVelocityX, dy: secondBubbleNewVelocityY)
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
    }

    /// Snaps the `gameBubble` to the grid position indicated by `row` and `col`.
    private func snapToGrid(_ gameBubble: GameBubble, row: Int, col: Int) {
        gameBubble.position = gameViewController.getBubblePosition(row: row, col: col)
        gameBubble.physicsBody?.isResting = true
        gameLogic.addToBubbleGridModel(gameBubble: gameBubble)
        newlySnappedBubbles.append(gameBubble)
        postNotification(name: Constants.notifyNewlySnappedGameBubble,
                         userInfo: ["GameBubble": gameBubble])
    }

    /// Drops out the `gameBubble` from bottom of grid.
    private func dropOutFromBottom(_ gameBubble: GameBubble) {
        remove(gameObject: gameBubble)
    }

    /// Returns true if the `touchLocation` is within the firing angle range.
    private func isWithinFiringAngleRange(_ touchLocation: CGPoint) -> Bool {
//        let offset = touchLocation - gameViewController.getCannonPosition()
//        let angle = Double(atan2(offset.x, -offset.y))
//
//        return angle > Constants.leftFireAngleBound &&
//               angle < Constants.rightFireAngleBound
        return true
    }

}
