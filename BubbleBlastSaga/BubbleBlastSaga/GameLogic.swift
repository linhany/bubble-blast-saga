//
//  GameLogic.swift
//  GameEngine
//
//  Created by Yong Lin Han on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

// MARK: - `GameLogicDelegate` protocol.
protocol GameLogicDelegate {

    /// Initialise the game by adding `GameBubble`s in `gridState` as `GameObject`s.
    func initialiseGame(gridState: [[GameBubble?]])

    /// Remove `gameBubble` as a `GameObject` in the scene.
    func removeGameBubbleFromScene(_ gameBubble: GameBubble)
}

// MARK - `GameLogic`
/// `GameLogic` is responsible for the algorithms that
/// takes place after a `GameBubble` is snapped into the grid, to handle
/// gameplay specific logic for our bubble game.
/// It uses the `modelManager` to handle the grid state of existing `GameBubbles`.
/// It does not know about the `scene` or `GameObjects`.
/// It delegates handling of `GameObjects` and `scene` to `GameLogicDelegate`.
class GameLogic {
    /// The `modelManager` that manages bubble grid state.
    private var modelManager: ModelManager

    /// The ViewController for the view this game is taking place on.
    /// Uses it to get the location of `GameBubble` in the grid based on its `position`.
    private var gameViewController: GameViewController

    /// The `TraversalHelper` for our `GameLogic`.
    private var traversalHelper: TraversalHelper

    /// Notification center to notify observers of removed bubbles.
    private let nc = NotificationCenter.default

    var delegate: GameLogicDelegate? {
        didSet {
            guard let delegate = delegate else {
                return
            }
            delegate.initialiseGame(gridState: modelManager.getGridState())
            removeUnattachedBubbles()
        }
    }

    init(modelManager: ModelManager,
         gameViewController: GameViewController) {
        self.modelManager = modelManager
        self.gameViewController = gameViewController
        traversalHelper =
            TraversalHelper(getBubbleIndexPathHelper: gameViewController.getBubbleIndexPath,
                            getBubbleRowAndColHelper: gameViewController.getBubbleRowAndCol,
                            getNeighboursOfBubbleHelper: modelManager.getNeighboursOfBubbleAt,
                            getBubbleHelper: modelManager.getBubbleAt)
    }

    /// Game is won if all normal bubbles are cleared from grid.
    func isGameWon() -> Bool {
        return !modelManager.isAnyNormalBubblesInGrid()
    }

    func handleNewlySnappedBubble(_ newBubble: GameBubble) {
        addToBubbleGridModel(gameBubble: newBubble)
        handleSurroundingSpecialBubbles(with: newBubble)
        removeConnectedBubblesOfSameColor(as: newBubble)
        removeUnattachedBubbles()
    }

    func isBubbleTypeInGrid(_ bubbleType: BubbleType) -> Bool {
        return modelManager.isBubbleTypeInGrid(bubbleType)
    }

    private func handleSurroundingSpecialBubbles(with bubble: GameBubble) {
        handleSurroundingSpecialBubblesOfType(.star, with: bubble)
        handleSurroundingSpecialBubblesOfType(.lightning, with: bubble)
        handleSurroundingSpecialBubblesOfType(.bomb, with: bubble)
    }

    private func handleSurroundingSpecialBubblesOfType(_ bubbleType: BubbleType, with bubble: GameBubble) {
        guard let (row, col) = gameViewController.getBubbleRowAndCol(bubble: bubble),
              let neighbors = modelManager.getNeighboursOfBubbleAt(row: row, column: col) else {
                assertionFailure("GameBubble must be in grid!")
                return
        }
        for neighbor in neighbors {
            if neighbor.type == bubbleType {
                activate(bubble: neighbor, with: bubble)
            }
        }
    }

    /// Activates a bubble, by removing it, and unleashing any special effect it has.
    private func activate(bubble: GameBubble, with activatorBubble: GameBubble ) {
        switch bubble.type {
        case .bomb:
            bombAllAdjacentBubbles(as: bubble)
        case .lightning:
            zapAllBubblesOnSameRow(as: bubble)
        case .star:
            activateAllBubblesWithSameType(as: activatorBubble, with: bubble)
        case .indestructible: return
        default: removePoppedGameBubbles([bubble])
        }
    }

    private func bombAllAdjacentBubbles(as bombBubble: GameBubble) {
        guard let bombBubble = bombBubble as? BombBubble else {
            assertionFailure("Bubble must be a BombBubble")
            return
        }
        guard let bubblesToBomb = getAdjacentBubbles(of: bombBubble) else {
            return
        }
        removeBombBubble(gameBubble: bombBubble)
        for bubble in bubblesToBomb {
            activate(bubble: bubble, with: bombBubble)
        }
    }

    private func zapAllBubblesOnSameRow(as lightningBubble: GameBubble) {
        guard let lightningBubble = lightningBubble as? LightningBubble else {
            assertionFailure("Bubble must be a LightningBubble")
            return
        }
        guard let bubblesToZap = getBubblesOnSameRow(as: lightningBubble) else {
            return
        }
        removeLightningBubble(gameBubble: lightningBubble)
        for bubble in bubblesToZap {
            activate(bubble: bubble, with: lightningBubble)
        }
    }

    private func activateAllBubblesWithSameType(as bubble: GameBubble, with starBubble: GameBubble) {
        guard let starBubble = starBubble as? StarBubble else {
            assertionFailure("Bubble must be a StarBubble")
            return
        }
        let bubblesOfSameType = getAllBubblesOfSameType(as: bubble)
        removePoppedGameBubbles([bubble, starBubble])
        for bubbleOfSameType in bubblesOfSameType {
            activate(bubble: bubbleOfSameType, with: starBubble)
        }
    }

    private func getAdjacentBubbles(of gameBubble: GameBubble) -> [GameBubble]? {
        guard let (row, col) = gameViewController.getBubbleRowAndCol(bubble: gameBubble),
            let neighbors = modelManager.getNeighboursOfBubbleAt(row: row, column: col) else {
                assertionFailure("GameBubble is not in the grid!")
                return nil
        }
        return neighbors
    }

    /// Excludes the gameBubble itself.
    private func getBubblesOnSameRow(as gameBubble: GameBubble) -> [GameBubble]? {
        guard let (row, col) = gameViewController.getBubbleRowAndCol(bubble: gameBubble) else {
            assertionFailure("GameBubble must be in the grid!")
            return nil
        }
        var bubbles: [GameBubble] = []
        let isRowEven = row % 2 == 0
        let noOfColumns = isRowEven
            ? Constants.noOfColumnsInEvenRowOfGameGrid
            : Constants.noOfColumnsInOddRowOfGameGrid
        for column in 0..<noOfColumns {
            guard col != column else {
                continue
            }
            if let bubble = modelManager.getBubbleAt(row: row, column: column) {
                bubbles.append(bubble)
            }
        }

        return bubbles
    }

    /// Excluding the gameBubble itself.
    private func getAllBubblesOfSameType(as gameBubble: GameBubble) -> [GameBubble] {
        var bubblesToRemove: [GameBubble] = []
        let grid = modelManager.getGridState()
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if let bubble = modelManager.getBubbleAt(row: row, column: col),
                    bubble !== gameBubble {
                    if gameBubble.type == bubble.type {
                        bubblesToRemove.append(bubble)
                    }
                }
            }
        }
        return bubblesToRemove
    }

    /// Adds `gameBubble` to grid.
    private func addToBubbleGridModel(gameBubble: GameBubble) {
        guard let position = gameBubble.position else {
            assertionFailure("Game Bubble must have a position!")
            return
        }
        guard let (row, col) = gameViewController.getBubbleGridRowAndColFromPosition(position: position) else {
            assertionFailure("Game Bubble position must be on grid!")
            return
        }
        modelManager.setBubbleAt(row: row, column: col, with: gameBubble)
    }

    /// Removes `gameBubble` from grid.
    private func removeFromBubbleGridModel(gameBubble: GameBubble) {
        guard let position = gameBubble.position else {
            assertionFailure("Game Bubble must have a position!")
            return
        }
        guard let (row, col) = gameViewController.getBubbleGridRowAndColFromPosition(position: position) else {
            assertionFailure("Game Bubble position must be on grid!")
            return
        }
        modelManager.removeBubbleAt(row: row, column: col)
    }

    private func removeConnectedBubblesOfSameColor(as targetBubble: GameBubble) {
        guard let bubblesToRemove =
            traversalHelper.clusterCheckTraversal(from: targetBubble) else {
            return
        }
        if bubblesToRemove.count >= Constants.gameBubbleClusterLimit {
            removePoppedGameBubbles(bubblesToRemove)
        }
    }

    private func removeUnattachedBubbles() {
        guard let attachedBubbles = traversalHelper.attachedCheckTraversal() else {
            return
        }
        let bubblesToRemove = getUnattachedBubbles(from: attachedBubbles)
        removeDisconnectedGameBubbles(bubblesToRemove)
    }

    /// Gets the unattached bubbles in the grid as an array of GameBubbles.
    /// Uses the `attached` set to check against every bubble in the grid.
    /// Bubbles in grid that are not in this set are unattached.
    private func getUnattachedBubbles(from attached: Set<IndexPath>) -> [GameBubble] {
        var bubblesToRemove: [GameBubble] = []
        let grid = modelManager.getGridState()

        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if let bubble = modelManager.getBubbleAt(row: row, column: col) {
                    guard let bubbleIndexPath =
                        gameViewController.getBubbleIndexPath(bubble: bubble) else {
                        assertionFailure("Bubble's location should be in the grid!")
                        continue
                    }
                    if !attached.contains(bubbleIndexPath) {
                        bubblesToRemove.append(bubble)
                    }
                }
            }
        }
        return bubblesToRemove
    }

    private func removeDisconnectedGameBubbles(_ gameBubbles: [GameBubble]) {
        for gameBubble in gameBubbles {
            removeGameBubble(gameBubble)
            nc.post(name: Notification.Name(Constants.notifyRemoveDisconnectedGameBubble),
                    object: nil,
                    userInfo: [Constants.gameBubbleIdentifier: gameBubble])
        }
    }

    private func removePoppedGameBubbles(_ gameBubbles: [GameBubble]) {
        for gameBubble in gameBubbles {
            removeGameBubble(gameBubble)
            nc.post(name: Notification.Name(Constants.notifyRemovePoppedGameBubble),
                    object: nil,
                    userInfo: [Constants.gameBubbleIdentifier: gameBubble])
        }
    }

    private func removeLightningBubble(gameBubble: GameBubble) {
        removeGameBubble(gameBubble)
        nc.post(name: Notification.Name(Constants.notifyRemoveLightningBubble),
                object: nil,
                userInfo: [Constants.gameBubbleIdentifier: gameBubble])
    }

    private func removeBombBubble(gameBubble: GameBubble) {
        removeGameBubble(gameBubble)
        nc.post(name: Notification.Name(Constants.notifyRemoveBombBubble),
                object: nil,
                userInfo: [Constants.gameBubbleIdentifier: gameBubble])
    }

    /// Removes `gameBubble` from the model and delegates removal of it from the game scene.
    private func removeGameBubble(_ gameBubble: GameBubble) {
        guard let delegate = delegate else {
            assertionFailure("Delegate not set!")
            return
        }
        delegate.removeGameBubbleFromScene(gameBubble)
        removeFromBubbleGridModel(gameBubble: gameBubble)
    }

}
