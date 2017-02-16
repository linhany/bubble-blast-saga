//
//  GameViewController.swift
//  GameEngine
//
//  Created by Yong Lin Han on 5/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet private var cannonImage: CannonImageView!
    @IBOutlet private var bubbleGrid: UICollectionView!
    @IBOutlet private var cannonArea: UIView!
    internal var modelManager: ModelManager? = nil
    internal var gameView: GameView? = nil

    override func viewDidAppear(_ animated: Bool) {
        bubbleGrid.isUserInteractionEnabled = false
        presentGameScene()
    }

    func presentGameScene() {
        guard let modelManager = modelManager else {
            fatalError("Model Manager reference was not passed!")
        }
        guard let modelManagerCopy = modelManager.copy() as? ModelManager else {
            fatalError("Copying failed!")
        }
        let scene = GameLevelScene(modelManager: modelManagerCopy,
                                   gameViewController: self,
                                   gameProjectileQueue: initialiseQueue())
        guard let gameView = view as? GameView else {
            fatalError("GameView class not subclassed properly!")
        }

        gameView.present(scene, with: AnimationRenderer())
        self.gameView = gameView
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        stopGame()
    }

    @IBAction func retryButtonPressed(_ sender: UIButton) {
        retryGame()
    }

    func stopGame() {
        guard let gameView = gameView else {
            return
        }
        gameView.stopPresenting()
    }

    func retryGame() {
        guard let gameView = gameView else {
            return
        }
        gameView.stopPresenting()
        presentGameScene()
    }

    func animateCannonFire() {
        cannonImage.startAnimating()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: view)
        let offset = touchLocation - getCannonPosition()
        cannonImage.rotateCannon(offset: offset)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: view)
        let offset = touchLocation - getCannonPosition()
        cannonImage.rotateCannon(offset: offset)
    }

    func getBubbleWidth() -> CGFloat {
        return view.frame.width/CGFloat(Constants.noOfColumnsInEvenRowOfGameGrid)
    }

    func getBubbleRadius() -> CGFloat {
        return getBubbleWidth()/2
    }

    func getCannonPosition() -> CGPoint {
        return cannonArea.center
    }

    func getNextBubblePosition() -> CGPoint {
        let origin = cannonArea.frame.origin
        let x = origin.x + getBubbleRadius()
        let y = origin.y
        return CGPoint(x: x, y: y)
    }

    func getBubbleRowAndCol(bubble: GameBubble) -> (Int, Int)? {
        guard let position = bubble.position else {
            assertionFailure("Target bubble does not have a position!")
            return nil
        }
        return getBubbleGridRowAndCol(position: position)
    }

    func getBubbleIndexPath(bubble: GameBubble) -> IndexPath? {
        guard let position = bubble.position else {
            assertionFailure("Target bubble does not have a position!")
            return nil
        }
        return getBubbleGridIndexPath(position: position)
    }

    func getBubblePosition(row: Int, col: Int) -> CGPoint {
        return rowAndColToCGPoint(row: row, col: col)
    }

    func getBubbleGridRowAndCol(position: CGPoint) -> (Int, Int)? {
        return rowAndColFromPoint(point: position)
    }

    private func getBubbleGridIndexPath(position: CGPoint) -> IndexPath? {
        return indexPathFromPoint(point: position)
    }

    private func rowAndColFromPoint(point: CGPoint) -> (Int, Int)? {
        if point.y > bubbleGrid.frame.size.height {
            return nil
        }
        guard let indexPath = indexPathFromPoint(point: point) else {
            return nil
        }
        return rowAndColFromIndexPath(indexPath: indexPath)
    }

    private func rowAndColFromIndexPath(indexPath: IndexPath) -> (Int, Int) {
        return (indexPath.section, indexPath.row)
    }

    private func indexPathFromPoint(point: CGPoint) -> IndexPath? {
        return bubbleGrid.indexPathForItem(at: point)
    }

    private func rowAndColToCGPoint(row: Int, col: Int) -> CGPoint {
        let indexPath = IndexPath(row: col, section: row)
        guard let cell = bubbleGrid.cellForItem(at: indexPath) else {
            fatalError("ERROR")
        }
        return cell.center
    }

    private func indexPathToCGPoint(indexPath: IndexPath) -> CGPoint {
        guard let cell = bubbleGrid.cellForItem(at: indexPath) else {
            fatalError("ERROR")
        }
        return cell.center
    }

    private func makeFixtureData() {
        guard let modelManager = modelManager else {
            fatalError("Model Manager reference was not passed!")
        }
        for row in 0..<Constants.noOfRowsInGameGrid-2 {
            let columns = row % 2 == 0
                ? Constants.noOfColumnsInEvenRowOfGameGrid : Constants.noOfColumnsInOddRowOfGameGrid
            for col in 0..<columns {
                modelManager.setBubbleAt(row: row, column: col, with: modelManager.buildRandomNormalBubble())
            }
        }
    }

    private func initialiseQueue() -> Queue<GameBubble> {
        guard let modelManager = modelManager else {
            fatalError("Model Manager reference was not passed!")
        }
        var projectileQueue = Queue<GameBubble>()
        for _ in 0..<1000 {
            projectileQueue.enqueue(modelManager.buildRandomNormalBubble())
        }
        return projectileQueue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension GameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.noOfRowsInGameGrid
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionIsEven = section % 2 == 0
        return sectionIsEven
            ? Constants.noOfColumnsInEvenRowOfGameGrid
            : Constants.noOfColumnsInOddRowOfGameGrid
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
            Constants.bubbleGridCellReuseIdentifier,
            for: indexPath as IndexPath) as? BubbleGridCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        let width = collectionView.bounds.width
        cell.initImageView(gridWidth: width, isBorderHidden: true)

        return cell
    }

}

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        let diameterOfGameCell =
            Int(collectionView.frame.size.width) / Constants.noOfColumnsInEvenRowOfGameGrid
        let radiusOfGameCell = CGFloat(diameterOfGameCell / 2)

        // This offset was obtained through trial and error
        // in attempting to pack the grid cells closely together.
        let offsetForRowSpacing = CGFloat(-(diameterOfGameCell / 8))

        let evenSectionEdgeInset = UIEdgeInsets(top: 0.0,
                                                left: 0.0,
                                                bottom: 0.0,
                                                right: 0.0)
        let oddSectionEdgeInset = UIEdgeInsets(top: offsetForRowSpacing,
                                               left: radiusOfGameCell,
                                               bottom: offsetForRowSpacing,
                                               right: radiusOfGameCell)
        let sectionIsEven = section % 2 == 0
        return sectionIsEven ? evenSectionEdgeInset : oddSectionEdgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfItemsPerRow = Constants.noOfColumnsInEvenRowOfGameGrid
        let size = Int(collectionView.bounds.width / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
}
