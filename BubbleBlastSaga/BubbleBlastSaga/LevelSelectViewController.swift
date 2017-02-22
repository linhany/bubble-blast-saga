//
//  LevelSelectViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The Controller responsible for the Level Selection screen of our Bubble Game.
/// This screen contains a scrollable `CollectionView` with its cells as
/// the stored levels.
class LevelSelectViewController: UIViewController {

    /// Outlets to storyboard elements.
    @IBOutlet fileprivate var levelsGrid: UICollectionView!
    @IBOutlet private var headerText: UITextField!

    /// The data source for `levelsGrid`.
    fileprivate var levelNamesAndImages: [(String, UIImage)] = []

    /// The number of items to display in a single row in `levelsGrid`.
    fileprivate let noOfLevelsInARow = Constants.levelSelectionNoOfLevelsInARow

    /// A Set of `IndexPath`s, of levels that the user has marked for deletion.
    fileprivate var isToBeDeleted = Set<IndexPath>()

    /// The variable that tracks if user is currently in Delete Mode.
    fileprivate var isDeleteModeOn = false

    /// Variables to be assigned by the ViewController performing segue to this class.
    internal var modelManager: ModelManager?
    internal var storageManager: StorageManager?
    internal var unwindSegueIdentifier: String?

    // MARK - Overrides.

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage reference not passed.")
        }
        levelNamesAndImages = storageManager.getLevelNamesAndImagesFromDocumentDirectory()
        isDeleteModeOn = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.levelSelectPlayGameSegueIdentifier {
            guard let gameVC = segue.destination as? GameViewController else {
                return
            }
            guard let modelManagerCopy = modelManager?.copy() as? ModelManager else {
                fatalError("Copying failed!")
            }
            gameVC.modelManager = modelManagerCopy
            gameVC.unwindSegueIdentifier = Constants.gameUnwindToLevelSelectSegueIdentifier
        }
    }

    // MARK - Storyboard button actions.

    @IBAction func backToLevelSelectViewController(segue: UIStoryboardSegue) {
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        guard let unwindSegueIdentifier = unwindSegueIdentifier else {
            assertionFailure("Unwind segue identifier not assigned!")
            return
        }
        performSegue(withIdentifier: unwindSegueIdentifier, sender: self)
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if isDeleteModeOn {
            deleteMarkedLevels()
        }
        isToBeDeleted.removeAll()
        toggleMode()
        isDeleteModeOn
                ? setViewForDeleteMode(button: sender)
                : setViewForNormalMode(button:sender)
    }

    // MARK: - Private helpers.

    private func deleteMarkedLevels() {
        guard let storageManager = storageManager else {
            fatalError("Storage reference not passed!")
        }
        for indexPath in isToBeDeleted {
            let index = indexPathToArrayIndex(indexPath)
            let (name, _) = levelNamesAndImages[index]
            storageManager.deleteLevel(withFileName: name)
        }
        levelNamesAndImages = storageManager.getLevelNamesAndImagesFromDocumentDirectory()
        levelsGrid.reloadData()
    }

    private func toggleMode() {
        isDeleteModeOn = !isDeleteModeOn
    }

    private func setViewForDeleteMode(button: UIButton) {
        button.setTitle(Constants.levelSelectionDeleteModeDeleteButtonTitle, for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        headerText.text = Constants.levelSelectionDeleteModeHeaderText
        headerText.textColor = UIColor.red
    }

    private func setViewForNormalMode(button: UIButton) {
        button.setTitle(Constants.levelSelectionDeleteButtonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        headerText.text = Constants.levelSelectionHeaderText
        headerText.textColor = UIColor.white
    }

    fileprivate func indexPathToArrayIndex(_ indexPath: IndexPath) -> Int {
        let row = indexPath.section
        let col = indexPath.row
        return row * noOfLevelsInARow + col
    }

    fileprivate func noOfRowsInGrid() -> Int {
        let noOfLevels = levelNamesAndImages.count
        var noOfRows = noOfLevels / noOfLevelsInARow

        // We need to take the ceiling of this computation if
        // there is a last row that is partially filled.
        // We take ceiling manually by incrementing instead of using ceil()
        // since floating point representation might lead to errors.
        if hasPartiallyFilledLastRow() {
            noOfRows += 1
        }

        return noOfRows
    }

    fileprivate func noOfLevelsInLastRow() -> Int {
        let noOfLevels = levelNamesAndImages.count
        return hasPartiallyFilledLastRow()
                ? noOfLevels % noOfLevelsInARow
                : noOfLevelsInARow
    }

    /// Returns true if `number` is the index of last row in grid.
    fileprivate func isLastRow(_ number: Int) -> Bool {
        // Row indexes are zero-indexed.
        return number == noOfRowsInGrid() - 1
    }

    /// Returns true if there the last row is partially filled.
    private func hasPartiallyFilledLastRow() -> Bool {
        // If the noOfLevels is not divisible by noOfLevelsInARow,
        // that means the last row is not fully filled up.
        let noOfLevels = levelNamesAndImages.count
        return noOfLevels % noOfLevelsInARow != 0
    }
}

// MARK - Extension UICollectionViewDataSource.

extension LevelSelectViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return noOfRowsInGrid()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLastRow(section) ? noOfLevelsInLastRow() : noOfLevelsInARow
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.levelCellReuseIdentifier,
            for: indexPath as IndexPath) as? LevelCell else {
                fatalError("Cell not assigned the proper view subclass!")
        }

        let index = indexPathToArrayIndex(indexPath)
        let (name, image) = levelNamesAndImages[index]
        cell.setTitle(name)
        cell.setPreview(image)
        isToBeDeleted.contains(indexPath) ? cell.showRedBorder() : cell.hideBorder()

        return cell
    }

}

// MARK - Extension UICollectionViewDelegateFlowLayout.

extension LevelSelectViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isDeleteModeOn {
            toggleMarkForDeletion(indexPath: indexPath)
            return
        }

        let index = indexPathToArrayIndex(indexPath)
        let (name, _) = levelNamesAndImages[index]
        loadLevelIntoModel(levelName: name)
        performSegueSelectively()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let insetValue = CGFloat(Constants.levelSelectionCellInset)
        let edgeInset = UIEdgeInsets(top: insetValue,
                                     left: insetValue,
                                     bottom: insetValue,
                                     right: insetValue)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = Int(collectionView.bounds.width /
                CGFloat(Constants.levelSelectionCellSizeProportion))
        return CGSize(width: size, height: size)
    }

    /// Toggles the deletion status of the item at `indexPath`.
    /// Reloads the item at `indexPath` so the visual effect is shown to user.
    private func toggleMarkForDeletion(indexPath: IndexPath) {
        // Cannot use ternary operator here due to mismatched types..?
        if isToBeDeleted.contains(indexPath) {
            isToBeDeleted.remove(indexPath)
        } else {
            isToBeDeleted.insert(indexPath)
        }
        levelsGrid.reloadItems(at: [indexPath])
    }

    private func loadLevelIntoModel(levelName: String) {
        guard let modelManager = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage reference not passed.")
        }
        guard let (level, _) = storageManager.loadLevel(fromFile: levelName) else {
            assertionFailure("Loading is unsuccessful!")
            return
        }
        modelManager.loadGridState(gridState: level.gridState)
    }

    /// Chooses which segue to perform based on `unwindSegueIdentifier`.
    /// If `unwindSegueIdentifier` is `levelSelectUnwindToMenuSegueIdentifier`,
    /// then performs a segue to `GameViewController` to play the level.
    /// Otherwise, if `unwindSegueIdentifier` is `levelSelectUnwindToLevelDesignSegueIdentifier`,
    /// performs a segue to unwind to `LevelDesignViewController`.
    private func performSegueSelectively() {
        guard let unwindSegueIdentifier = unwindSegueIdentifier else {
            assertionFailure("Unwind segue identifier not assigned!")
            return
        }

        switch unwindSegueIdentifier {
        case Constants.levelSelectUnwindToMenuSegueIdentifier:
            performSegue(withIdentifier: Constants.levelSelectPlayGameSegueIdentifier,
                    sender: self)
        case Constants.levelSelectUnwindToLevelDesignSegueIdentifier:
            performSegue(withIdentifier: Constants.levelSelectUnwindToLevelDesignSegueIdentifier,
                    sender: self)
        default: assertionFailure("Should not reach here!")
        }
    }
}
