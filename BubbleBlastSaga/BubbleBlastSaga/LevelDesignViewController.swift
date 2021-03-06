//
//  LevelDesignViewController.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 23/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The Controller responsible for the level design view.
/// This view comprises of a bubble grid, a palette and
/// START, SAVE, LOAD, RESET buttons.
/// Responds to user interactions through buttons and gestures
/// by updating the grid state in model.
/// Updates the view upon notifications from the model.
class LevelDesignViewController: UIViewController {

    /// Outlets to storyboard elements.
    @IBOutlet private var paletteArea: UIView!
    @IBOutlet private var bubbleGrid: UICollectionView!
    @IBOutlet private var userFeedback: UILabel!

    /// Collection view required implementations.
    private var bubbleGridViewDataSource: BubbleGridViewDataSource?
    private var bubbleGridViewDelegate: BubbleGridViewDelegate?

    /// Variable to store the user's currently selected palette option.
    /// The palette options are all bubble types that can be in the
    /// game grid. The erase option is represented by the .empty BubbleType.
    private var selectedPaletteOption: BubbleType? = nil

    /// Notification center to receive updates from model, and update
    /// view accordingly.
    private var nc = NotificationCenter.default

    /// The timer used in showing user feedback.
    private var timer: Timer?

    /// Variables to be assigned by the ViewController performing segue to this class.
    internal var modelManager: ModelManager?
    internal var storageManager: StorageManager?

    /// Hides the status bar in this view,
    /// as our collection view covers the top of the screen.
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        guard let _ = modelManager,
              let _ = storageManager else {
            fatalError("Model/Storage manager reference not passed!")
        }
        connectBubbleGridViewDataSourceAndDelegates()
        addObserverForBubbleGridViewUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        modelManager?.reloadGridState()
    }

    @IBAction func backToLevelDesignViewController(segue: UIStoryboardSegue) {
    }

    // MARK: - Lower bar user interactions

    /// Palette options are implemented as buttons in the storyboard.
    /// Marks the user selected button visually and sets it
    /// as the `selectedPaletteOption`.
    @IBAction private func bubbleSelectorPressed(_ sender: UIButton) {
        markCurrentlySelectedButton(as: sender)
        setSelectedPaletteOption(as: sender)
    }

    @IBAction private func saveButtonPressed(_ sender: UIButton) {
        presentSaveLevelAlert()
    }

    @IBAction private func resetButtonPressed(_ sender: UIButton) {
        presentResetLevelAlert()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let modelManager = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage manager reference not passed!")
        }
        if segue.identifier == Constants.levelDesignToLevelSelectSegueIdentifier {
            guard let levelSelectVC = segue.destination as? LevelSelectViewController else {
                fatalError("Level design to level select segue failed!")
            }
            levelSelectVC.modelManager = modelManager
            levelSelectVC.storageManager = storageManager
            levelSelectVC.unwindSegueIdentifier = Constants.levelSelectUnwindToLevelDesignSegueIdentifier
        } else if segue.identifier == Constants.startGameLevelSegueIdentifier {
            guard let gameVC = segue.destination as? GameViewController else {
                fatalError("Level design to game level segue failed!")
            }
            guard let modelManagerCopy = modelManager.copy() as? ModelManager else {
                fatalError("Copying failed!")
            }
            gameVC.modelManager = modelManagerCopy
            gameVC.unwindSegueIdentifier = Constants.gameUnwindToLevelDesignSegueIdentifier
        }
    }

    // MARK: - Gesture recognizers

    /// Handles a tap from user on the bubble grid, by applying the
    /// `selectedPaletteOption` BubbleType to the tap location in the grid.
    /// However, if there is already a non-empty bubble at the tap
    /// location, and the selected palette option is not erase (.empty),
    /// then we will cycle through the available bubble types,
    /// excluding the .empty type.
    @IBAction private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }

        if isBubbleAbsent(at: indexPath) || isEraseOptionSelected() {
            guard let selectedPaletteOption = selectedPaletteOption else {
                return
            }
            setBubble(at: indexPath, with: selectedPaletteOption)
        } else {
            cycleBubble(at: indexPath)
        }
    }

    /// Handles a pan from user on the bubble grid, by applying the
    /// `selectedPaletteOption` BubbleType from the pan start location
    /// to the pan end location in the grid.
    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let selectedPaletteOption = selectedPaletteOption else {
            return
        }
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }

        setBubble(at: indexPath, with: selectedPaletteOption)
    }

    /// Handles a long press from user on the bubble grid, by erasing
    /// the existing bubble at the press location, if there is any.
    @IBAction private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let indexPath = bubbleGrid.indexPathForItem(at: sender.location(in: bubbleGrid)) else {
            return
        }
        // Prevent long press dragging from deleting.
        if sender.state == .began {
            setBubble(at: indexPath, with: .empty)
            animateButtonCorrespondingToBubbleType(type: .empty)
        }
    }

    // MARK: - Helper functions

    private func connectBubbleGridViewDataSourceAndDelegates() {
        bubbleGridViewDataSource =
            BubbleGridViewDataSource(collectionView: bubbleGrid, isInLevelDesigner: true)
        bubbleGridViewDelegate =
            BubbleGridViewDelegate(collectionView: bubbleGrid)
    }

    private func addObserverForBubbleGridViewUpdate() {
        nc.addObserver(
            forName: Notification.Name(rawValue: Constants.notifyBubbleGridUpdated),
            object: nil,
            queue: nil,
            using: updateView)
    }

    /// Handles a `notification` from Model component,
    /// and updates view accordingly.
    private func updateView(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let (row, column) = userInfo[Constants.notifyPosition]
                as? (Int, Int),
            let bubbleType = userInfo[Constants.notifyBubbleType]
                as? BubbleType else {
                    assertionFailure("Poster did not post it right.")
                    return
        }

        let indexPath = IndexPath(row: column, section: row)
        guard let bubbleGridCell = bubbleGrid.cellForItem(at: indexPath)
            as? BubbleGridCell else {
                return
        }

        bubbleGridCell.updateImageView(with: bubbleType)
    }

    /// Presents a save level alert to the user.
    /// Includes a text field, confirm, and cancel option.
    /// The user specifies a file name for this new level in the text field,
    /// and the save will be done upon confirmation.
    /// If the user specifies a file name that already exists,
    /// the old file will be overwritten by the new file.
    private func presentSaveLevelAlert() {
        let alertController =
            UIAlertController.alertForSaveLevel { (isSaveConfirmed, userInput) in
            guard isSaveConfirmed else {
                self.showFeedback(feedback: Constants.feedbackLevelSavingCancelled)
                return
            }
            guard self.isUserInputLevelNameValid(userInput: userInput) else {
                self.showFeedback(feedback: Constants.feedbackLevelNameRequired)
                return
            }
            self.saveGridStateWithFeedbackToModel(fileName: userInput)
        }

        self.present(alertController, animated: true, completion: nil)
    }

    /// Checks if `userInput` for a level name is valid.
    /// A valid input is one that contains more than one
    /// non-whitespace character, and is within the
    /// `levelNameCharacterCountLimit` value as defined in Constants file.
    private func isUserInputLevelNameValid(userInput: String) -> Bool {
        let hasAtLeastOneNonWhitespaceCharacter =
                userInput.trimmingCharacters(in: .whitespaces) != Constants.emptyString
        let isWithinCharacterCountLimit =
                userInput.characters.count <= Constants.levelNameCharacterCountLimit
        return hasAtLeastOneNonWhitespaceCharacter && isWithinCharacterCountLimit
    }

    /// Saves the `Level` with `fileName` to file,
    /// along with an image of the `bubbleGrid` for level selection preview.
    /// Shows feedback to user to inform if the save was successful.
    private func saveGridStateWithFeedbackToModel(fileName: String) {
        guard let modelManager = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage manager reference not passed!")
        }
        let gridState = modelManager.getGridState()
        let level = Level(gridState: gridState, fileName: fileName)
        let levelPreviewImage = takeScreenshotOfBubbleGrid()
        let isSaveSuccessful =
            storageManager.saveLevel(level: level, levelPreviewImage: levelPreviewImage)
        isSaveSuccessful
                ? showFeedback(feedback: Constants.feedbackLevelSavingSuccessful)
                : showFeedback(feedback: Constants.feedbackLevelSavingUnsuccessful)
    }

    private func takeScreenshotOfBubbleGrid() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bubbleGrid.frame.size, false, 0)
        let rect = CGRect(x: -bubbleGrid.frame.origin.x,
                y: -bubbleGrid.frame.origin.y,
                width: view.bounds.size.width,
                height: view.bounds.size.height)
        view.drawHierarchy(in: rect, afterScreenUpdates: true)
        guard let levelPreviewImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Cannot get image!")
        }
        return levelPreviewImage
    }

    /// Presents a reset level alert to the user.
    /// Includes a confirm and cancel option.
    /// Upon confirmation, the grid state will be cleared of all bubbles.
    private func presentResetLevelAlert() {
        let uiAlert = UIAlertController.alertForResetLevel { (isResetConfirmed) in
            guard isResetConfirmed else {
                return
            }
            self.resetGridStateWithFeedback()
        }

        self.present(uiAlert, animated: true, completion: nil)
    }

    private func resetGridStateWithFeedback() {
        guard let modelManager = modelManager else {
            fatalError("Model manager reference not passed!")
        }
        if modelManager.isGridStateEmpty() {
            showFeedback(feedback: Constants.feedbackLevelResetAlreadyEmpty)
            return
        }
        modelManager.resetGridState()
        showFeedback(feedback: Constants.feedbackLevelReset)
    }

    /// Marks the currently selected button by user in palette
    /// with a black border around the item, with an animation
    /// to indicate the selection.
    private func markCurrentlySelectedButton(as button: UIButton) {
        clearAllPaletteButtonsMarkings()
        guard let button = button as? PaletteButton else {
            assertionFailure("Palette Buttons not assigned the correct view class!")
            return
        }
        button.showBorder()
        button.animatePress()
    }

    /// Clears all palette button markings to ensure that only
    /// the one selected by user is marked.
    private func clearAllPaletteButtonsMarkings() {
        for subview in paletteArea.subviews {
            guard let button = subview as? PaletteButton else {
                continue
            }
            button.hideBorder()
        }
    }

    /// Assigns a button on the palette as the currently selected button.
    /// Precondition that the buttons have their tags set corresponding
    /// to their bubble type value.
    private func setSelectedPaletteOption(as button: UIButton) {
        selectedPaletteOption = BubbleType(rawValue: button.tag)
    }

    private func isBubbleAbsent(at indexPath: IndexPath) -> Bool {
        return currentBubble(at: indexPath) == nil
    }

    private func isEraseOptionSelected() -> Bool {
        return selectedPaletteOption == .empty
    }

    /// Sets a bubble at the grid location, specified by the `indexPath`,
    /// with a `bubbleType`.
    /// If the `bubbleType` is .empty, removes any bubble at that location.
    private func setBubble(at indexPath: IndexPath, with bubbleType: BubbleType) {
        guard let modelManager = modelManager else {
            fatalError("Model manager reference not passed!")
        }
        let bubbleGridRow = indexPath.section
        let bubbleGridColumn = indexPath.row
        let newBubble = modelManager.buildBubble(withBubbleType: bubbleType)
        modelManager.setBubbleAt(row: bubbleGridRow, column: bubbleGridColumn, with: newBubble)
    }

    /// Cycles through the bubble at the grid location, specified by the `indexPath`.
    /// This cycling excludes the .empty bubble, and uses an animation on the currently
    /// cycled button to indicate to user the order of cycle.
    private func cycleBubble(at indexPath: IndexPath) {
        guard let bubbleCurrentlyInGrid = currentBubble(at: indexPath) else {
            return
        }
        guard let nextBubbleType = getNextBubbleTypeForCycle(currentBubbleType: bubbleCurrentlyInGrid.type) else {
            return
        }
        setBubble(at: indexPath, with: nextBubbleType)
        animateButtonCorrespondingToBubbleType(type: nextBubbleType)
    }

    /// Returns the next `bubbleType` when we cycle through the bubble types.
    /// Precondition that the .empty `bubbleType` has the largest integer value,
    /// and that the integer values assigned to bubble types are consecutive and
    /// ascending, in terms of the order we wish to cycle through them in.
    private func getNextBubbleTypeForCycle(currentBubbleType: BubbleType) -> BubbleType? {
        let nextBubbleTypeValue = currentBubbleType.rawValue + 1
        guard var nextBubbleType = BubbleType(rawValue: nextBubbleTypeValue) else {
            return nil
        }
        // If we are now at the empty bubble, loop it back
        // to the first bubble.
        guard let firstBubbleType = BubbleType(rawValue: BubbleType.getFirstBubbleTypeRawValue()) else {
            return nil
        }
        if nextBubbleType == .empty {
            nextBubbleType = firstBubbleType
        }
        return nextBubbleType
    }

    /// Returns the current bubble at the grid location, specified by `indexPath`.
    /// Returns nil if no bubble exists at that grid location.
    private func currentBubble(at indexPath: IndexPath) -> GameBubble? {
        guard let modelManager = modelManager else {
            fatalError("Model manager reference not passed!")
        }
        let bubbleGridRow = indexPath.section
        let bubbleGridColumn = indexPath.row
        return modelManager.getBubbleAt(row: bubbleGridRow, column: bubbleGridColumn)
    }

    /// Animates a button on the palette, that corresponds to the bubbleType `type`.
    /// Intended for use when the currently selected palette item is not the bubbleType
    /// being applied to the grid. (Long press, cycle functionality.)
    private func animateButtonCorrespondingToBubbleType(type: BubbleType) {
        guard let button = getButtonCorrespondingToBubbleType(type: type) else {
            return
        }
        guard let paletteButton = button as? PaletteButton else {
            return
        }
        paletteButton.animatePress()
    }

    /// Returns the button on the palette corresponding to a bubbleType `type`.
    /// Precondition that the button's tag value is set to correspond to its bubble type.
    /// Returns nil if such a button is not found.
    private func getButtonCorrespondingToBubbleType(type: BubbleType) -> UIButton? {
        var currentButton: UIButton? = nil
        for subview in paletteArea.subviews {
            guard let button = subview as? UIButton else {
                continue
            }
            if button.tag == type.rawValue {
                currentButton = button
                break
            }
        }

        return currentButton
    }

    /// Shows feedback to user in the form of a small text label.
    /// This feedback automatically disappears after a set amount of time.
    fileprivate func showFeedback(feedback: String) {
        userFeedback.text = feedback

        timer = Timer.scheduledTimer(timeInterval: Constants.feedbackTimer,
                                     target: self,
                                     selector: #selector(self.dismissFeedback),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc private func dismissFeedback() {
        userFeedback.text = Constants.emptyString
        timer?.invalidate()
    }
}
