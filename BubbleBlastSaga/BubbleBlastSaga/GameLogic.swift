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

    func handleNewlySnappedBubble(_ newBubble: GameBubble) {
        removeConnectedBubblesOfSameColor(as: newBubble)
        removeUnattachedBubbles()
    }

    /// Adds `gameBubble` to grid.
    func addToBubbleGridModel(gameBubble: GameBubble) {
        guard let position = gameBubble.position else {
            assertionFailure("Game Bubble must have a position!")
            return
        }
        guard let (row, col) = gameViewController.getBubbleGridRowAndCol(position: position) else {
            assertionFailure("Game Bubble position must be on grid!")
            return
        }
        modelManager.setBubbleAt(row: row, column: col, with: gameBubble)
    }

    /// Removes `gameBubble` from grid.
    func removeFromBubbleGridModel(gameBubble: GameBubble) {
        guard let position = gameBubble.position else {
            assertionFailure("Game Bubble must have a position!")
            return
        }
        guard let (row, col) = gameViewController.getBubbleGridRowAndCol(position: position) else {
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
            removeClusteredGameBubbles(bubblesToRemove)
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
                    userInfo: ["GameBubble": gameBubble])
        }
    }

    private func removeClusteredGameBubbles(_ gameBubbles: [GameBubble]) {
        for gameBubble in gameBubbles {
            removeGameBubble(gameBubble)
            nc.post(name: Notification.Name(Constants.notifyRemoveClusteredGameBubble),
                    object: nil,
                    userInfo: ["GameBubble": gameBubble])
        }
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
