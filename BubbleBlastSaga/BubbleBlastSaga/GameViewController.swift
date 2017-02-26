//
//  GameViewController.swift
//  GameEngine
//
//  Created by Yong Lin Han on 5/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit
import PhysicsEngine

/// The Controller responsible for starting `GameLevelScene` through the `GameView`,
/// and handling user interactions for views that are not `GameObject`s in the scene,
/// e.g. cannon, navigation buttons, end game screen.
/// Also exposes some functions that deal with positions of `GameObject`s in the scene.
class GameViewController: UIViewController {

    /// Outlets to storyboard elements.
    @IBOutlet private var boundsLine: UIImageView!
    @IBOutlet private var restartButton: RoundedButton!
    @IBOutlet private var backButton: RoundedButton!
    @IBOutlet private var cannonImage: CannonImageView!
    @IBOutlet private var endGameScreen: UIStackView!
    @IBOutlet private var gameScoreText: UITextField!
    @IBOutlet private var remainingCountText: UITextField!
    @IBOutlet private var timerText: UITextField!
    @IBOutlet private var bubbleGrid: UICollectionView!
    @IBOutlet private var cannonArea: UIView!

    /// Collection view required implementations.
    private var bubbleGridViewDataSource: BubbleGridViewDataSource?
    private var bubbleGridViewDelegate: BubbleGridViewDelegate?

    /// The `GameView` which presents the `GameLevelScene`.
    private var gameView: GameView? = nil

    /// Variables to be assigned by the ViewController performing segue to this class.
    internal var modelManager: ModelManager? = nil
    internal var unwindSegueIdentifier: String?

    private var timer: Timer?
    private var isGameOngoing = false
    private var shotsFired = 0
    private var playTime = 0

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
        incrementShotsFiredCount()
        if GameConfig.isCannonShotsLimited {
            updateRemainingCountText()
        }
    }

    func updateGameScore(_ score: Int) {
        gameScoreText.text = String(score)
    }

    /// Stops the game and displays the `message`.
    func endGame(message: String) {
        guard isGameOngoing else {
            return
        }
        isGameOngoing = false
        stopGame()
        var endGameMessages: [String] = []
        if isDefaultWin() {
            endGameMessages.append(getDefaultWinMessage())
            showEndGameScreen(endGameStats: endGameMessages)
            return
        }
        endGameMessages.append(message)
        endGameMessages.append(getGamePlayScoreMessage())
        endGameMessages.append(getShotsFiredMessage())
        endGameMessages.append(getPlayTimeMessage())

        if GameConfig.isCannonShotsLimited {
            let shotsLeftMessages = handleShotsLeftBonus()
            for message in shotsLeftMessages {
                endGameMessages.append(message)
            }
        }
        if GameConfig.isTimed {
            let timeLeftMessages = handleTimeLeftBonus()
            for message in timeLeftMessages {
                endGameMessages.append(message)
            }
        }
        if message == Constants.endGameWinText {
            let winMessage = handleWinBonus()
            endGameMessages.append(winMessage)
        }
        showEndGameScreen(endGameStats: endGameMessages)
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
        self.shotsFired = 0
        self.playTime = 0
        self.isGameOngoing = true
        initGameTimer()
    }

    private func initGameTimer() {
        if GameConfig.isTimed {
            timerText.text = String(GameConfig.timeLimit)
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.updateTime),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func updateTime() {
        playTime += 1
        if GameConfig.isTimed {
            updateTimeLimit()
        }
    }

    private func updateTimeLimit() {
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
            endGame(message: Constants.endGameLoseText)
            timer?.invalidate()
        }
    }

    private func initCannonShotCount() -> Int {
        var noOfBubbles = Int.max
        if GameConfig.isCannonShotsLimited {
            noOfBubbles = GameConfig.cannonShots
            remainingCountText.text = String(noOfBubbles)
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
        isGameOngoing = false
        gameView.stopPresenting()
        timer?.invalidate()
    }

    private func animateCannonRotate(towards position: CGPoint) {
        let offset = position - getCannonProjectilePosition()
        cannonImage.rotateCannon(offset: offset)
    }

    private func getDefaultWinMessage() -> String {
        return Constants.endGameDefaultWinText
    }

    private func getGamePlayScoreMessage() -> String {
        guard let currentGameScore = gameScoreText?.text else {
            fatalError("Must have a current game score.")
        }
        return Constants.messageGamePlayScore + currentGameScore
    }

    private func handleShotsLeftBonus() -> [String] {
        var messages: [String] = []
        guard let shotsLeft = remainingCountText.text,
            let shotsLeftValue = Int(shotsLeft) else {
                fatalError("Must have shots left!")
        }
        guard let currentGameScore = gameScoreText?.text,
            var currentGameScoreValue = Int(currentGameScore) else {
                fatalError("Must have score!")
        }
        let shotsLeftBonus = shotsLeftValue * Int(GameConfig.bubblesLeftBonus)
        currentGameScoreValue += shotsLeftBonus
        updateGameScore(currentGameScoreValue)
        var message = Constants.messageShotsLeft + shotsLeft
        messages.append(message)
        message = Constants.messageShotsLeftBonus + String(shotsLeftBonus)
        messages.append(message)
        return messages
    }

    private func handleTimeLeftBonus() -> [String] {
        var messages: [String] = []
        guard let timeLeft = timerText?.text,
              let timeLeftValue = Int(timeLeft) else {
            fatalError("Must have time left!")
        }
        guard let currentGameScore = gameScoreText?.text,
              var currentGameScoreValue = Int(currentGameScore) else {
            fatalError("Must have score!")
        }
        let timeLeftBonus = timeLeftValue * Int(GameConfig.timeLeftBonus)
        currentGameScoreValue += timeLeftBonus
        updateGameScore(currentGameScoreValue)

        var message = Constants.messageTimeLeft + timeLeft + Constants.messageTimeSeconds
        messages.append(message)
        message = Constants.messageTimeLeftBonus + String(timeLeftBonus)
        messages.append(message)
        return messages
    }

    private func getShotsFiredMessage() -> String {
        let message = Constants.messageBubblesFired + String(shotsFired)
        return message
    }

    private func getPlayTimeMessage() -> String {
        let message = Constants.messagePlayTime + String(playTime) + Constants.messageTimeSeconds
        return message
    }

    private func isDefaultWin() -> Bool {
        return shotsFired == 0
    }

    private func handleWinBonus() -> String {
        guard let currentGameScore = gameScoreText?.text,
              let currentGameScoreValue = Int(currentGameScore) else {
            fatalError("Must have a current game score.")
        }
        let newGameScoreValue = currentGameScoreValue * Constants.winBonusMultiplier
        gameScoreText.text = String(newGameScoreValue)
        return Constants.messageWinBonus
    }

    private func showEndGameScreen(endGameStats: [String]) {
        guard let currentGameScore = gameScoreText?.text else {
            fatalError("Must have a current game score.")
        }
        var endGameStats = endGameStats
        let finalScoreMessage = Constants.messageFinalScore + currentGameScore
        endGameStats.append(finalScoreMessage)
        for endGameStat in endGameStats {
            let textField = UITextField()
            textField.text = endGameStat
            textField.textAlignment = .center
            textField.textColor = UIColor.white
            guard let fontName = textField.font?.fontName else {
                fatalError("Must have font name")
            }
            textField.font = UIFont(name: fontName, size: CGFloat(Constants.endGameScreenFontSize))
            endGameScreen.addArrangedSubview(textField)
        }
        gameScoreText.isHidden = true
        remainingCountText.isHidden = true
        timerText.isHidden = true
    }

    private func disableUserInteractionOnViews() {
        endGameScreen.isUserInteractionEnabled = false
        remainingCountText.isUserInteractionEnabled = false
        bubbleGrid.isUserInteractionEnabled = false
        gameScoreText.isUserInteractionEnabled = false
        timerText.isUserInteractionEnabled = false
    }

    private func alignBoundsLine() {
        let bubbleGridSize = bubbleGrid.collectionViewLayout.collectionViewContentSize
        let targetOriginX = CGFloat(0.0)
        let targetOriginY = bubbleGridSize.height

        boundsLine.frame.origin = CGPoint(x: targetOriginX, y: targetOriginY)
    }

    private func updateRemainingCountText() {
        guard let text = remainingCountText.text else {
            return
        }
        guard let textIntValue = Int(text) else {
            assertionFailure("Must have an integer value.")
            return
        }
        let decrementedCount = textIntValue - 1
        remainingCountText.text = String(decrementedCount)
    }

    private func clearScreen() {
        for subview in endGameScreen.subviews {
            subview.removeFromSuperview()
        }
        gameScoreText.text = String(0)
        gameScoreText.isHidden = false
        remainingCountText.isHidden = false
        timerText.isHidden = false
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

    private func incrementShotsFiredCount() {
        shotsFired += 1
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
