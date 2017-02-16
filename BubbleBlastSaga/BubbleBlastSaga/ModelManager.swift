//
//  ModelManager.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// Handles game objects models.
class ModelManager: NSObject {

    /// 2D array representing state of bubble grid in offset layout.
    fileprivate var gridState: [[GameBubble?]]

    /// Notification Center to notify view when model is updated.
    private let nc = NotificationCenter.default

    /// Initialisation sets up a fixed size 2D array that models the game grid.
    required override init() {
        gridState = []
        super.init()
        for row in 0..<Constants.noOfRowsInGameGrid {
            gridState.append([])
            let currentRowCount = isEven(row)
                                ? Constants.noOfColumnsInEvenRowOfGameGrid
                                : Constants.noOfColumnsInOddRowOfGameGrid

            gridState[row] = [GameBubble?](repeating: nil,
                                           count: currentRowCount)
        }
    }

    /// Loads a `gridState` into model.
    /// This `gridState` must be a 2D array that follows the game constants
    /// defining number of rows and columns.
    /// We iterate through the whole array and set each bubble individually
    /// so that the view will be notified of changes.
    func loadGridState(gridState: [[GameBubble?]]) {
        guard isValidGridState(gridState) else {
            assertionFailure("Grid state must follow game constants!")
            return
        }
        for row in 0..<gridState.count {
            for column in 0..<gridState[row].count {
                setBubbleAt(row: row, column: column,
                            with: gridState[row][column])
            }
        }
    }

    func reloadGridState() {
        loadGridState(gridState: gridState)
    }

    /// Assigns a `bubble` to the location in grid state specified by `row` and `column`.
    /// Notifies view of this change.
    func setBubbleAt(row: Int, column: Int, with bubble: GameBubble?) {
        guard isInGrid(row: row, column: column) else {
            return
        }

        gridState[row][column] = bubble
        nc.post(name: Notification.Name(rawValue: Constants.notifyBubbleGridUpdated),
                object: nil,
                userInfo: [Constants.notifyBubbleType: bubble?.type ?? BubbleType.empty,
                           Constants.notifyPosition: (row, column)])
    }

    /// Removes bubble at a location in grid state specified by `row` and `column`.
    /// Notifies view of this change.
    func removeBubbleAt(row: Int, column: Int) {
        guard isInGrid(row: row, column: column) else {
            return
        }
        setBubbleAt(row: row, column: column, with: nil)
    }

    /// Returns the `GameBubble` at a location in grid state specified by `row` and `column`.
    /// Returns nil if no bubble exists in the location.
    func getBubbleAt(row: Int, column: Int) -> GameBubble? {
        guard isInGrid(row: row, column: column) else {
            return nil
        }
        return gridState[row][column]
    }

    /// Returns neighbours of a bubble, specified by its
    /// `row` and `column` in the grid.
    /// Returns an empty array if bubble has no neighbours.
    /// Returns nil if bubble is not in the grid.
    /// Neighbours are surrounding cells of this GameBubble.
    func getNeighboursOfBubbleAt(row: Int, column: Int) -> [GameBubble]? {
        guard isInGrid(row: row, column: column) else {
            return nil
        }
        var neighbours: [GameBubble] = []
        let neighbourEvenRowOffsets = [(-1, -1), (1, -1), (0, -1), (-1, 0), (1, 0), (0, 1)]
        let neighbourOddRowOffsets = [(-1, 1), (1, 1), (0, -1), (-1, 0), (1, 0), (0, 1)]
        let neighbourOffsets = isEven(row) ? neighbourEvenRowOffsets : neighbourOddRowOffsets

        for (rowOffset, columnOffset) in neighbourOffsets {
            let neighbourRow = row + rowOffset
            let neighbourColumn = column + columnOffset
            guard isInGrid(row: neighbourRow, column: neighbourColumn) else {
                continue
            }
            guard let neighbour = getBubbleAt(row: neighbourRow, column: neighbourColumn) else {
                continue
            }
            neighbours.append(neighbour)
        }

        return neighbours
    }

    /// Returns the internal representation of the grid state.
    func getGridState() -> [[GameBubble?]] {
        return gridState
    }

    /// Resets the grid state by removing all bubbles present.
    func resetGridState() {
        for row in 0..<gridState.count {
            for column in 0..<gridState[row].count {
                removeBubbleAt(row: row, column: column)
            }
        }
    }

    /// Factory type function to build a bubble given a bubble `type`.
    /// Returns nil if an empty bubble is supplied as the `type`.
    func buildBubble(withBubbleType type: BubbleType) -> GameBubble? {
        switch type {
        case .normalRed: return NormalBubble(color: .red)
        case .normalOrange: return NormalBubble(color: .orange)
        case .normalBlue: return NormalBubble(color: .blue)
        case .normalGreen: return NormalBubble(color: .green)
        case .normalPurple: return NormalBubble(color: .purple)
        case .normalGray: return NormalBubble(color: .gray)
        case .normalPink: return NormalBubble(color: .pink)
        case .bomb: return BombBubble()
        case .lightning: return LightningBubble()
        case .star: return StarBubble()
        case .indestructible: return IndestructibleBubble()

        case .empty: return nil
        }
    }

    /// Returns a random normal bubble.
    func buildRandomNormalBubble() -> GameBubble {
        let colorInt = Int(arc4random_uniform(UInt32(Constants.noOfNormalBubbleTypes)))
        guard let color = NormalBubbleColor(rawValue: colorInt) else {
            fatalError("Random function is wrong!")
        }
        return NormalBubble(color: color)
    }

    /// Checks if the parameter `gridState` is valid by iterating through every row
    /// and checking if its dimensions fit the game constants.
    private func isValidGridState(_ gridState: [[GameBubble?]]) -> Bool {
        guard gridState.count == Constants.noOfRowsInGameGrid else {
            return false
        }
        for row in 0..<gridState.count {
            let currentRowCount = isEven(row)
                ? Constants.noOfColumnsInEvenRowOfGameGrid
                : Constants.noOfColumnsInOddRowOfGameGrid
            guard currentRowCount == gridState[row].count else {
                return false
            }
        }
        return true
    }

    /// Checks if a specified `row` and `column` position is inside the grid.
    private func isInGrid(row: Int, column: Int) -> Bool {
        if row < 0 || row >= Constants.noOfRowsInGameGrid {
            return false
        }
        return isEven(row)
            ? column >= 0 && column < Constants.noOfColumnsInEvenRowOfGameGrid
            : column >= 0 && column < Constants.noOfColumnsInOddRowOfGameGrid
    }

    /// Convenience function to check if a row is even.
    private func isEven(_ row: Int) -> Bool {
        return row % 2 == 0
    }

}

extension ModelManager: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let theCopy = type(of: self).init()
        theCopy.gridState = self.gridState
        return theCopy
    }
}
