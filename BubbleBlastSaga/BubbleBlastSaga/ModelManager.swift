//
//  ModelManager.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// Handles game objects models.
class ModelManager {

    /// 2D array representing state of bubble grid in offset layout.
    private var gridState: [[GameBubble?]]

    /// Notification Center to notify view when model is updated.
    private let nc = NotificationCenter.default

    /// Initialisation sets up a fixed size 2D array that models the game grid.
    init() {
        gridState = []
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
        case .empty: return nil
        }
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
