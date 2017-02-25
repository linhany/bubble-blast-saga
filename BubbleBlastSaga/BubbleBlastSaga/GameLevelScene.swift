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
class GameLevelScene: Scene {

    /// The ViewController for the view this scene is rendered on.
    /// Uses it to set `GameObject` positions.
    fileprivate let gameViewController: GameViewController

    /// The `GameLogic` for our Bubble Game.
    fileprivate let gameLogic: GameLogic

    /// Helper to generate random bubbles lazily.
    fileprivate var randomBubbleHelper: RandomBubbleHelper

    /// The `projectileQueue` only holds the `GameBubble`s currently shown
    /// in this scene, since the `GameBubble`s are lazily generated.
    fileprivate var projectileQueue: Queue<GameBubble>

    /// The newly snapped bubbles in the grid.
    fileprivate var newlySnappedBubbles: [GameBubble] = []

    /// Boolean variable to keep track of whether game is lost.
    fileprivate var isGameLost = false

    init(modelManager: ModelManager,
         gameViewController: GameViewController,
         randomBubbleHelper: RandomBubbleHelper) {
        self.gameLogic = GameLogic(modelManager: modelManager,
                                   gameViewController: gameViewController)
        self.gameViewController = gameViewController
        self.randomBubbleHelper = randomBubbleHelper
        self.projectileQueue = Queue<GameBubble>()
        super.init()
        physicsBody = PhysicsBody(edgeLoopFrom: gameViewController.view.frame)
        physicsWorld.contactDelegate = self
        gameLogic.delegate = self
        setUpProjectilesInScene()
    }

    // MARK - Override functions.

    override func update() {
        // Skip updating unless game is still ongoing and there is a newly snapped bubble.
        guard isGameOngoing(), !newlySnappedBubbles.isEmpty else {
            return
        }
        for newBubble in newlySnappedBubbles {
            gameLogic.handleNewlySnappedBubble(newBubble)
        }
        newlySnappedBubbles.removeAll()
        modifyProjectileQueueIfNeeded()
    }

    override func handleTouch(at touchLocation: CGPoint) {
        guard isWithinFiringAngleRange(touchLocation) else {
            return
        }
        guard let gameProjectile = getNextProjectile() else {
            assertionFailure("Projectile was not set up!")
            return
        }
        addCircularPhysicsBody(gameBubble: gameProjectile)
        let direction = getProjectileDirection(touchLocation: touchLocation)
        addVelocity(toProjectile: gameProjectile, inDirection: direction)
        gameViewController.animateCannonFire()
        showNextProjectilesInScene()
    }

    // MARK - Private helper functions.

    private func isGameOngoing() -> Bool {
        if isGameLost {
            gameViewController.endGame(message: Constants.endGameLoseText)
            return false
        }
        if gameLogic.isGameWon() {
            gameViewController.endGame(message: Constants.endGameWinText)
            return false
        }
        return true
    }

    /// The `gameBubble` should be an existing GameObject in this scene.
    /// The physicsBodyRadius is at an adjusted reduced percentage to allow for
    /// better projectile movement, allowing projectiles to pass through tight spaces without
    /// snapping prematurely.
    fileprivate func addCircularPhysicsBody(gameBubble: GameObject) {
        let radius = gameViewController.getBubbleRadius()
        let physicsBodyRadius =
                radius * CGFloat(Constants.gameBubbleCollisionAdjustedPercentage)
        gameBubble.physicsBody = PhysicsBody(circleOfRadius: physicsBodyRadius)
    }

    /// Returns the direction for projectile launching as a normalized CGPoint.
    private func getProjectileDirection(touchLocation: CGPoint) -> CGPoint {
        let offset = touchLocation - gameViewController.getCannonProjectilePosition()
        let direction = offset.normalized()
        return direction
    }

    /// Adds velocity to the `gameProjectile` in the `direction` given.
    private func addVelocity(toProjectile gameProjectile: GameObject, inDirection direction: CGPoint) {
        gameProjectile.physicsBody?.velocity = CGVector(dx: direction.x*2, dy: direction.y*2)
    }

    // MARK: - Projectile management helpers.

    /// Should only be called on initialisation to set up the first two projectiles
    /// in the scene.
    private func setUpProjectilesInScene() {
        guard isGameOngoing() else {
            return
        }
        guard let firstProjectile =
        randomBubbleHelper.nextBubble(isAccountingForBubblesGenerated: true),
              let secondProjectile =
              randomBubbleHelper.nextBubble(isAccountingForBubblesGenerated: true) else {
            assertionFailure("Should have at least two bubbles.")
            return
        }

        addAtCannonPosition(firstProjectile)
        projectileQueue.enqueue(firstProjectile)

        addAtNextProjectilePosition(secondProjectile)
        projectileQueue.enqueue(secondProjectile)
    }

    /// Dequeue the next projectile from `projectileQueue`.
    private func getNextProjectile() -> GameBubble? {
        guard let projectileToFire = try? projectileQueue.dequeue() else {
            assertionFailure("Queue cannot be empty! Game should be over.")
            return nil
        }
        return projectileToFire
    }

    /// Shows the next two projectiles in scene after a projectile has been fired.
    private func showNextProjectilesInScene() {
        guard let nextProjectile = try? projectileQueue.peek() else {
            assertionFailure("Queue cannot be empty! Game should be over.")
            return
        }

        // Move to Cannon position.
        nextProjectile.position = gameViewController.getCannonProjectilePosition()
        postNotification(name: Constants.notifyLoadingCannonGameBubble,
                userInfo: ["GameBubble": nextProjectile])

        guard let secondNextProjectile =
        randomBubbleHelper.nextBubble(isAccountingForBubblesGenerated: true) else {
            // Current projectile is the last.
            return
        }
        addAtNextProjectilePosition(secondNextProjectile)
        projectileQueue.enqueue(secondNextProjectile)
    }

    /// Handles corner case: Upon firing of a projectile, the projectile clears
    /// all bubbles of an existing type in the game grid.
    /// Since the next two projectiles are already shown and might be of this newly cleared
    /// color, we swap these two projectiles out if needed to another color that is still in
    /// the grid.
    /// This should be called only if the game is still ongoing.
    private func modifyProjectileQueueIfNeeded() {
        guard isGameOngoing() else {
            return
        }
        guard var firstProjectile = try? projectileQueue.dequeue() else {
            assertionFailure("Queue cannot be empty! Game should be over.")
            return
        }
        firstProjectile = swapIfNotInGridAnymore(firstProjectile, isCannonAreaBubble: true)
        projectileQueue.enqueue(firstProjectile)

        guard var secondProjectile = try? projectileQueue.dequeue() else {
            // First projectile is the last projectile.
            return
        }
        secondProjectile = swapIfNotInGridAnymore(secondProjectile, isCannonAreaBubble: false)
        projectileQueue.enqueue(secondProjectile)
    }

    /// Swaps the `gameBubble` out if its type is no longer in the game grid.
    private func swapIfNotInGridAnymore(_ gameBubble: GameBubble,
                                        isCannonAreaBubble: Bool) -> GameBubble {
        let isGameBubbleTypeInGrid = gameLogic.isBubbleTypeInGrid(gameBubble.type)

        if !isGameBubbleTypeInGrid {
            remove(gameObject: gameBubble)

            guard let replacedProjectile =
            randomBubbleHelper.nextBubble(isAccountingForBubblesGenerated: false) else {
                fatalError("Should never return nil when not accounting for count")
            }
            isCannonAreaBubble
                    ? addAtCannonPosition(replacedProjectile) : addAtNextProjectilePosition(replacedProjectile)
            return replacedProjectile
        }
        return gameBubble
    }

    /// Adds the `gameBubble` at the cannon position in the game scene.
    private func addAtCannonPosition(_ gameBubble: GameBubble) {
        let bubbleWidth = gameViewController.getBubbleWidth()
        add(gameObject: gameBubble)
        gameBubble.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        gameBubble.position = gameViewController.getCannonProjectilePosition()
    }

    /// Adds the `gameBubble` at the next projectile position in the game scene.
    private func addAtNextProjectilePosition(_ gameBubble: GameBubble) {
        let bubbleWidth = gameViewController.getBubbleWidth()
        add(gameObject: gameBubble)
        gameBubble.size = CGSize(width: bubbleWidth, height: bubbleWidth)
        gameBubble.position = gameViewController.getNextProjectilePosition()
    }

    /// Returns true if the `touchLocation` is within the firing angle range.
    private func isWithinFiringAngleRange(_ touchLocation: CGPoint) -> Bool {
        let offset = touchLocation - gameViewController.getCannonProjectilePosition()
        let angle = Double(atan2(offset.x, -offset.y))

        return angle > Constants.leftFireAngleBound &&
                angle < Constants.rightFireAngleBound
    }
}

// MARK - GameLogicDelegate protocol.

extension GameLevelScene: GameLogicDelegate {

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
                gameBubble.position = gameViewController.getBubblePositionFromRowAndCol(row: row, col: col)
                gameBubble.size = CGSize(width: width, height: width)
                addCircularPhysicsBody(gameBubble: gameBubble)
            }
        }
    }

}

// MARK - PhysicsContactDelegate protocol.

extension GameLevelScene: PhysicsContactDelegate {

    func handleCollisions(_ collisions: [Collision]) {
        for collision in collisions {
            handleCollision(collision)
        }
    }

    // MARK - Private collision handlers.

    private func handleCollision(_ collision: Collision) {
        let physicsBody = collision.physicsBody
        let otherPhysicsBody = collision.otherPhysicsBody
        guard let projectile = physicsBody.physicsBodyOwner as? GameBubble,
              !physicsBody.isResting else {
            return
        }
        switch collision.collisionType {
        case .circleWithCircle: otherPhysicsBody.isResting
                ? snapToClosestGridCell(projectile) : bounceProjectilesOffEachOther(collision)
        case .circleWithTopOfEdgeLoop: snapToClosestGridCell(projectile)
        case .circleWithLeftOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithRightOfEdgeLoop: bounceProjectileOffWall(projectile)
        case .circleWithBottomOfEdgeLoop: dropOutFromBottom(projectile)
        }
    }

    /// Handles case of two moving projectiles colliding with each other.
    private func bounceProjectilesOffEachOther(_ collision: Collision) {
        let firstPhysicsBody = collision.physicsBody
        let secondPhysicsBody = collision.otherPhysicsBody
        moveProjectilesApart(firstPhysicsBody: firstPhysicsBody, secondPhysicsBody: secondPhysicsBody)
        changeProjectilesVelocity(firstPhysicsBody: firstPhysicsBody, secondPhysicsBody: secondPhysicsBody)
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
            gameViewController.getBubbleGridRowAndColFromPosition(position: CGPoint(x: x, y: y)) {
                snapToGrid(projectile, row: row, col: col)
                return
            }
        }
        // Closest grid cell is not found, that means that the user is trying to append
        // to a GameBubble in the last row of our grid. Game is lost.
        remove(gameObject: projectile)
        isGameLost = true
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

    /// Move projectiles away from each other so they no longer overlap.
    private func moveProjectilesApart(firstPhysicsBody: PhysicsBody, secondPhysicsBody: PhysicsBody) {
        guard let firstBodyPosition = firstPhysicsBody.position,
              let firstBodyRadius = (firstPhysicsBody.physicsBodyType as? Circle)?.radius,
              let secondBodyPosition = secondPhysicsBody.position,
              let secondBodyRadius = (secondPhysicsBody.physicsBodyType as? Circle)?.radius else {
            assertionFailure("Bodies must be circles and have positions!")
            return
        }

        let midpoint = (firstBodyPosition + secondBodyPosition) / 2
        let firstBodyNewPosition = midpoint +
                ((firstBodyPosition - secondBodyPosition).normalized()) * firstBodyRadius
        let secondBodyNewPosition = midpoint +
                ((secondBodyPosition - firstBodyPosition).normalized()) * secondBodyRadius
        firstPhysicsBody.position = firstBodyNewPosition
        secondPhysicsBody.position = secondBodyNewPosition
    }

    /// Changes projectiles' velocities to move them in the right direction and speed
    /// after collision with each other.
    private func changeProjectilesVelocity(firstPhysicsBody: PhysicsBody, secondPhysicsBody: PhysicsBody) {
        guard let firstBodyPosition = firstPhysicsBody.position,
              let secondBodyPosition = secondPhysicsBody.position else {
            assertionFailure("Bodies must be circles and have positions!")
            return
        }
        let firstBodyVelocity = firstPhysicsBody.velocity
        let secondBodyVelocity = secondPhysicsBody.velocity
        let normalized = (secondBodyPosition - firstBodyPosition).normalized()
        let pValue = firstBodyVelocity.dx * normalized.x +
                firstBodyVelocity.dy * normalized.y -
                secondBodyVelocity.dx * normalized.x -
                secondBodyVelocity.dy * normalized.y

        let firstBodyNewVelocityX = firstBodyVelocity.dx - (pValue * normalized.x)
        let firstBodyNewVelocityY = firstBodyVelocity.dy - (pValue * normalized.y)
        let secondBodyNewVelocityX = secondBodyVelocity.dx + (pValue * normalized.x)
        let secondBodyNewVelocityY = secondBodyVelocity.dy + (pValue * normalized.y)

        firstPhysicsBody.velocity =
                CGVector(dx: firstBodyNewVelocityX, dy: firstBodyNewVelocityY)
        secondPhysicsBody.velocity =
                CGVector(dx: secondBodyNewVelocityX, dy: secondBodyNewVelocityY)
    }

    /// Snaps the `gameBubble` to the grid position indicated by `row` and `col`.
    private func snapToGrid(_ gameBubble: GameBubble, row: Int, col: Int) {
        gameBubble.position = gameViewController.getBubblePositionFromRowAndCol(row: row, col: col)
        gameBubble.physicsBody?.isResting = true
        newlySnappedBubbles.append(gameBubble)
        postNotification(name: Constants.notifyNewlySnappedGameBubble,
                userInfo: ["GameBubble": gameBubble])
    }

    /// Drops out the `gameBubble` from bottom of grid.
    private func dropOutFromBottom(_ gameBubble: GameBubble) {
        remove(gameObject: gameBubble)
    }
}
