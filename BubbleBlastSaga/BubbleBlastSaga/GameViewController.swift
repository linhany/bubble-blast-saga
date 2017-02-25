//
//  GameViewController.swift
//  GameEngine
//
//  Created by Yong Lin Han on 5/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The Controller responsible for starting `GameLevelScene` through the `GameView`,
/// and handling user interactions for views that are not `GameObject`s in the scene,
/// e.g. cannon, navigation buttons, end game screen.
/// Also exposes some functions that deal with positions of `GameObject`s in the scene.
class GameViewController: UIViewController {

    /// Outlets to storyboard elements.
    @IBOutlet private var boundsLine: UIImageView!
    @IBOutlet private var endGameText: UITextField!
    @IBOutlet private var remainingCountText: UITextField!
    @IBOutlet private var restartButton: RoundedButton!
    @IBOutlet private var backButton: RoundedButton!
    @IBOutlet private var cannonImage: CannonImageView!
    @IBOutlet private var gameScoreText: UITextField!
    @IBOutlet private var timerText: UITextField!
    @IBOutlet private var bubbleGrid: UICollectionView!
    @IBOutlet private var cannonArea: UIView!

    /// Collection view required implementations.
    private var bubbleGridViewDataSource: BubbleGridViewDataSource?
    private var bubbleGridViewDelegate: BubbleGridViewDelegate?

    /// The `GameView` which presents the `GameLevelScene`.
    private var gameView: GameView? = nil
    private var randomBubbleHelper: RandomBubbleHelper? = nil

    /// Variables to be assigned by the ViewController performing segue to this class.
    internal var modelManager: ModelManager? = nil
    internal var unwindSegueIdentifier: String?

    private var timer: Timer?

    // MARK - Overrides.

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        connectBubbleGridViewDataSourceAndDelegates()
        clearScreen()
        alignBoundsLine()
    }

    override func viewDidAppear(_ animated: Bool) {
        disableUserInteractionOnViews()
        startGame()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        animateCannonRotate(towards: touch.location(in: view))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        animateCannonRotate(towards: touch.location(in: view))
    }

    // MARK - GameViewController provided API.

    func fireCannon() {
        cannonImage.startAnimating()
        updateRemainingCountText()
    }

    func updateGameScore(_ score: Int) {
        gameScoreText.text = String(score)
    }

    /// Stops the game and displays the `message`.
    func endGame(message: String) {
        stopGame()
        addBonusScore()
        endGameText.text = message
    }

    /// Only eligible for bonus score in limited shots or timed mode.
    private func addBonusScore() {
        if GameConfig.isCannonShotsLimited {
            guard let bubbleLeft = remainingCountText?.text,
                  let bubbleLeftValue = Int(bubbleLeft) else {
                fatalError("Must have count!")
            }
            guard let currentGameScore = gameScoreText?.text,
                  var currentGameScoreValue = Int(currentGameScore) else {
                fatalError("Must have a current game score.")
            }
            let bubbleLeftBonus = bubbleLeftValue * GameConfig.bubblesLeftBonus
            print(bubbleLeftBonus)
            currentGameScoreValue += bubbleLeftBonus
            updateGameScore(currentGameScoreValue)
        }
        if GameConfig.isTimed {
            guard let timeLeft = timerText?.text,
                  let timeLeftValue = Int(timeLeft) else {
                fatalError("Must have time!")
            }
            guard let currentGameScore = gameScoreText?.text,
                  var currentGameScoreValue = Int(currentGameScore) else {
                fatalError("Must have a current game score.")
            }
            let timeLeftBonus = timeLeftValue * Int(GameConfig.timeLeftBonus)
            print(timeLeftBonus)
            currentGameScoreValue += timeLeftBonus
            updateGameScore(currentGameScoreValue)
        }
    }

    /// Returns the width of a bubble in the `bubbleGrid`.
    func getBubbleWidth() -> CGFloat {
        return view.frame.width/CGFloat(Constants.noOfColumnsInEvenRowOfGameGrid)
    }

    /// Returns the radius of a bubble in the `bubbleGrid`.
    func getBubbleRadius() -> CGFloat {
        return getBubbleWidth()/2
    }

    /// Returns the position of a bubble projectile loaded into the cannon.
    func getCannonProjectilePosition() -> CGPoint {
        return cannonArea.center
    }

    /// Returns the position of the next bubble projectile shown to user.
    func getNextProjectilePosition() -> CGPoint {
        let origin = cannonArea.frame.origin
        let x = origin.x + getBubbleRadius()
        let y = origin.y
        return CGPoint(x: x, y: y)
    }

    /// Returns the row and column of a bubble in `bubbleGrid`.
    /// Returns nil if the bubble does not have a position, or if the bubble's
    /// position does not fit it into the `bubbleGrid`.
    func getBubbleRowAndCol(bubble: GameBubble) -> (Int, Int)? {
        guard let position = bubble.position else {
            assertionFailure("Target bubble does not have a position!")
            return nil
        }
        return getBubbleGridRowAndColFromPosition(position: position)
    }

    /// Returns the `IndexPath` of a bubble in `bubbleGrid`.
    /// Returns nil if the bubble does not have a position, or if the bubble's
    /// position does not fit it into the `bubbleGrid`.
    func getBubbleIndexPath(bubble: GameBubble) -> IndexPath? {
        guard let position = bubble.position else {
            assertionFailure("Target bubble does not have a position!")
            return nil
        }
        return positionToIndexPath(position: position)
    }

    /// Takes in a `row` and `column` of bubbleGrid, and returns the rightful
    /// `position` of a bubble located there.
    /// The `position` returned is the center point of bubble.
    /// Returns nil if the `row` and `column` given is not within the bubbleGrid.
    func getBubblePositionFromRowAndCol(row: Int, col: Int) -> CGPoint? {
        return rowAndColToPosition(row: row, col: col)
    }

    /// Takes in a `position` and returns the `row` and `column` that this `position`
    /// falls under for the bubbleGrid.
    /// Returns nil if `position` does lie within the grid.
    func getBubbleGridRowAndColFromPosition(position: CGPoint) -> (Int, Int)? {
        return positionToRowAndCol(position: position)
    }

    // MARK - Storyboard button actions.

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        stopGame()
        performUnwindSegue()
    }

    @IBAction private func retryButtonPressed(_ sender: UIButton) {
        clearScreen()
        retryGame()
    }

    // MARK - Private helpers.

    /// Starts the game by presenting the `GameLevelScene` with `GameView`.
    private func startGame() {
        guard let modelManager = modelManager else {
            fatalError("Model Manager reference was not passed!")
        }
        // Copy for retry functionality.
        guard let modelManagerCopy = modelManager.copy() as? ModelManager else {
            fatalError("Copying failed!")
        }
        let noOfBubbles = initCannonShotCount()

        let randomBubbleHelper =
                RandomBubbleHelper(bubbleTypeRawValueRange: BubbleType.getNormalBubblesRawValueRange(),
                        noOfBubbles: noOfBubbles,
                        modelManager: modelManagerCopy)
        let scene = GameLevelScene(modelManager: modelManagerCopy,
                                   gameViewController: self,
                                   randomBubbleHelper: randomBubbleHelper)
        guard let gameView = view as? GameView else {
            fatalError("GameView class not subclassed properly!")
        }

        gameView.present(scene, with: AnimationRenderer())
        self.gameView = gameView
        self.randomBubbleHelper = randomBubbleHelper
        initGameTimer()
    }

    private func initGameTimer() {
        if GameConfig.isTimed {
            timerText.text = String(GameConfig.timeLimit)
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                 target: self,
                                 selector: #selector(self.updateTimeLimit),
                                 userInfo: nil,
                                 repeats: true)
        }
    }

    @objc private func updateTimeLimit() {
        guard let timeLeft = timerText?.text else {
            assertionFailure("Must have time.")
            return
        }

        guard var timeLeftValue = Int(timeLeft) else {
            assertionFailure("Must be Int!")
            return
        }

        timeLeftValue -= 1
        timerText.text = String(timeLeftValue)
        if timeLeftValue <= 0 {
            endGame(message: "Time Limit!")
            timer?.invalidate()
        }
    }

    private func initCannonShotCount() -> Int {
        var noOfBubbles = Int.max
        if GameConfig.isCannonShotsLimited {
            noOfBubbles = GameConfig.cannonShots
            remainingCountText.text = String(noOfBubbles)
        } else {
            remainingCountText.text = Constants.infinity
        }
        return noOfBubbles
    }

    private func retryGame() {
        stopGame()
        startGame()
    }

    @objc private func stopGame() {
        guard let gameView = gameView else {
            return
        }
        gameView.stopPresenting()
        timer?.invalidate()
    }

    private func animateCannonRotate(towards position: CGPoint) {
        let offset = position - getCannonProjectilePosition()
        cannonImage.rotateCannon(offset: offset)
    }

    private func disableUserInteractionOnViews() {
        endGameText.isUserInteractionEnabled = false
        remainingCountText.isUserInteractionEnabled = false
        bubbleGrid.isUserInteractionEnabled = false
    }

    private func alignBoundsLine() {
        let bubbleGridSize = bubbleGrid.collectionViewLayout.collectionViewContentSize
        let targetOriginX = CGFloat(0.0)
        let targetOriginY = bubbleGridSize.height

        boundsLine.frame.origin = CGPoint(x: targetOriginX, y: targetOriginY)
    }

    private func updateRemainingCountText() {
        guard let text = remainingCountText.text,
                text != Constants.infinity else {
            return
        }
        guard let textIntValue = Int(text) else {
            assertionFailure("Must have an integer value.")
            return
        }
        remainingCountText.text = String(textIntValue - 1)
    }

    private func clearScreen() {
        endGameText.text = Constants.emptyString
        gameScoreText.text = String(0)
    }

    private func performUnwindSegue() {
        guard let unwindSegueIdentifier = unwindSegueIdentifier else {
            assertionFailure("Unwind segue identifier not set up!")
            return
        }
        performSegue(withIdentifier: unwindSegueIdentifier, sender: self)
    }

    private func connectBubbleGridViewDataSourceAndDelegates() {
        bubbleGridViewDataSource =
                BubbleGridViewDataSource(collectionView: bubbleGrid, isInLevelDesigner: false)
        bubbleGridViewDelegate =
                BubbleGridViewDelegate(collectionView: bubbleGrid)
    }

    // MARK - Index Path, Row/Column, Position helpers
    /// Note: Some of the following helper functions use the
    /// `bubbleGrid` to easily convert from one to the other.
    /// Nil will be returned in these functions if caller provides
    /// parameters that are outside the bubbleGrid.

    private func indexPathToPosition(indexPath: IndexPath) -> CGPoint? {
        guard let cell = bubbleGrid.cellForItem(at: indexPath) else {
            return nil
        }
        let position = cell.center
        return position
    }

    private func indexPathToRowAndCol(indexPath: IndexPath) -> (Int, Int) {
        let row = indexPath.section
        let col = indexPath.row
        return (row, col)
    }

    private func rowAndColToIndexPath(row: Int, col: Int) -> IndexPath {
        let indexPath = IndexPath(row: col, section: row)
        return indexPath
    }

    private func rowAndColToPosition(row: Int, col: Int) -> CGPoint? {
        let indexPath = IndexPath(row: col, section: row)
        return indexPathToPosition(indexPath: indexPath)
    }

    private func positionToIndexPath(position: CGPoint) -> IndexPath? {
        guard let indexPath = bubbleGrid.indexPathForItem(at: position) else {
            return nil
        }
        return indexPath
    }

    private func positionToRowAndCol(position: CGPoint) -> (Int, Int)? {
        guard let indexPath = positionToIndexPath(position: position) else {
            return nil
        }

        return indexPathToRowAndCol(indexPath: indexPath)
    }

}
