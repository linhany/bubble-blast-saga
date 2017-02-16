//
//  TraversalHelper.swift
//  GameEngine
//
//  Created by Yong Lin Han on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// A `TraversalHelper` for `GameLogic`.
/// Allows for refactoring of traversal code in future
/// without maintaining many parameters in functions.
struct TraversalHelper {
    /// Use IndexPath for efficiency of checking contains in a Set, 
    /// because our GameBubble is not Hashable.
    private var visited = Set<IndexPath>()
    private var bubblesToRemove: [GameBubble] = []
    private var queue = Queue<GameBubble>()
    private let getBubbleIndexPathHelper: (GameBubble) -> IndexPath?
    private let getBubbleRowAndColHelper: (GameBubble) -> (Int, Int)?
    private let getNeighboursOfBubbleHelper: (Int, Int) -> [GameBubble]?
    private let getBubbleHelper: (Int, Int) -> GameBubble?

    init(getBubbleIndexPathHelper: @escaping (GameBubble) -> IndexPath?,
         getBubbleRowAndColHelper: @escaping (GameBubble) -> (Int, Int)?,
         getNeighboursOfBubbleHelper: @escaping (Int, Int) -> [GameBubble]?,
         getBubbleHelper: @escaping (Int, Int) -> GameBubble?) {
        self.getBubbleIndexPathHelper = getBubbleIndexPathHelper
        self.getBubbleRowAndColHelper = getBubbleRowAndColHelper
        self.getNeighboursOfBubbleHelper = getNeighboursOfBubbleHelper
        self.getBubbleHelper = getBubbleHelper
    }

    /// Returns clustered bubbles with same color as `targetBubble`.
    /// Uses a slightly modified version of BFS whereby neighbours are only
    /// enqueued if they are of the same type.
    mutating func clusterCheckTraversal(from targetBubble: GameBubble) -> [GameBubble]? {
        resetDataStructures()
        bubblesToRemove.append(targetBubble)
        queue.enqueue(targetBubble)
        while !queue.isEmpty {
            // Checks and unwrapping.
            guard let bubble = try? queue.dequeue() else {
                fatalError("Queue cannot be empty!")
            }
            guard let bubbleIndexPath = getBubbleIndexPathHelper(bubble),
                let (row, col) = getBubbleRowAndColHelper(bubble),
                let neighbours = getNeighboursOfBubbleHelper(row, col) else {
                    assertionFailure("Bubble's location should be in the grid!")
                    return nil
            }
            if visited.contains(bubbleIndexPath) {
                continue
            }

            visited.insert(bubbleIndexPath)
            for neighbour in neighbours {
                guard let neighbourIndexPath = getBubbleIndexPathHelper(neighbour) else {
                    assertionFailure("Neighbour's location should be in the grid!")
                    continue
                }

                // Cluster check ignores non normal bubble neighbours.
                guard let coloredNeighbour = neighbour as? NormalBubble,
                      let coloredBubble = bubble as? NormalBubble else {
                    continue
                }
                if !visited.contains(neighbourIndexPath)
                    && coloredBubble.type == coloredNeighbour.type {
                    queue.enqueue(neighbour)
                    bubblesToRemove.append(neighbour)
                }
            }
        }
        return bubblesToRemove
    }

    /// Returns a set containing IndexPaths of attached bubbles.
    mutating func attachedCheckTraversal() -> Set<IndexPath>? {
        resetDataStructures()
        // For every bubble at top, we BFS it
        // Then we check which bubbles not visited.
        for column in 0..<Constants.noOfColumnsInEvenRowOfGameGrid {
            guard let topBubble = getBubbleHelper(0, column) else {
                // No bubble in that column.
                continue
            }
            //BFS this top bubble.
            queue.enqueue(topBubble)

            while !queue.isEmpty {
                guard let bubble = try? queue.dequeue() else {
                    fatalError("Queue should not be empty!")
                }
                guard let bubbleIndexPath = getBubbleIndexPathHelper(bubble),
                    let (row, col) = getBubbleRowAndColHelper(bubble),
                    let neighbours = getNeighboursOfBubbleHelper(row, col) else {
                        assertionFailure("Bubble's location should be in the grid!")
                        return nil
                }
                if visited.contains(bubbleIndexPath) {
                    continue
                }

                visited.insert(bubbleIndexPath)
                for neighbour in neighbours {
                    guard let neighbourIndexPath =
                          getBubbleIndexPathHelper(neighbour) else {
                            assertionFailure("Neighbour's location should be in the grid!")
                            continue
                    }
                    if !visited.contains(neighbourIndexPath) {
                        queue.enqueue(neighbour)
                    }
                }
            }
        }
        return visited
    }

    /// Helper function to reset all data structures used.
    /// Should be called in the beginning of every non-private function in this struct,
    /// other than the init function.
    private mutating func resetDataStructures() {
        visited.removeAll()
        bubblesToRemove.removeAll()
        queue.removeAll()
    }

}
