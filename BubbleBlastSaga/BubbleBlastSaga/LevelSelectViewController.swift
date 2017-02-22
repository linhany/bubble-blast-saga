//
//  LevelSelectViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class LevelSelectViewController: UIViewController {

    @IBOutlet var levelsGrid: UICollectionView!
    @IBOutlet var headerText: UITextField!
    internal var modelManager: ModelManager?
    internal var storageManager: StorageManager?
    internal var levelNamesAndImages: [(String, UIImage)] = []
    internal var unwindSegueIdentifier: String?
    fileprivate var isToBeDeleted = Set<IndexPath>()
    fileprivate var isDeleteModeOn = false

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let modelManager = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage reference not passed.")
        }
        levelNamesAndImages = storageManager.getLevelNamesAndImagesFromDocumentDirectory()
        isDeleteModeOn = false
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
        isToBeDeleted.removeAll()
        isDeleteModeOn = !isDeleteModeOn
        if isDeleteModeOn {
            // refactor into view?
            sender.setTitle("Confirm", for: .normal)
            sender.setTitleColor(UIColor.red, for: .normal)
            headerText.text = "Deletion is permanent! Mark levels to delete"
            headerText.textColor = UIColor.red
        } else {
            sender.setTitle("Delete", for: .normal)
            sender.setTitleColor(UIColor.white, for: .normal)
            headerText.text = "Level selection"
            headerText.textColor = UIColor.white
        }
    }

    @IBAction func backToLevelSelectViewController(segue: UIStoryboardSegue) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.levelSelectPlayGameSegueIndentifier {
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

    fileprivate func indexPathToArrayIndex(_ indexPath: IndexPath) -> Int {
        let row = indexPath.section
        let col = indexPath.row
        return row * 3 + col
    }
}

extension LevelSelectViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let noOfRows = levelNamesAndImages.count%3 == 0
        ? levelNamesAndImages.count/3 : levelNamesAndImages.count/3 + 1
        return noOfRows
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let noOfRows = levelNamesAndImages.count%3 == 0
            ? levelNamesAndImages.count/3 : levelNamesAndImages.count/3 + 1
        let noOfItemsInLastRow = levelNamesAndImages.count%3 == 0
            ? 3 : levelNamesAndImages.count%3
        return section == noOfRows-1 ? noOfItemsInLastRow : 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
            Constants.levelCellReuseIdentifier,
            for: indexPath as IndexPath) as? LevelCell else {
                fatalError("Cell not assigned the proper view subclass!")
        }
        let row = indexPath.section
        let col = indexPath.row
        let index = row * 3 + col
        let (name, image) = levelNamesAndImages[index]
        cell.setTitle(name)
        cell.setPreview(image)
        if isToBeDeleted.contains(indexPath) {
            cell.showRedBorder()
        } else {
            cell.hideBorder()
        }
        return cell
    }

}

extension LevelSelectViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.section
        let col = indexPath.row
        let index = row * 3 + col
        if isDeleteModeOn {
            if isToBeDeleted.contains(indexPath) {
                isToBeDeleted.remove(indexPath)
            } else {
                isToBeDeleted.insert(indexPath)
            }
            levelsGrid.reloadItems(at: [indexPath])
            return
        }
        let (name, _) = levelNamesAndImages[index]
        guard let (level, _) = storageManager?.loadLevel(fromFile: name) else {
            assertionFailure("Loading should be successful!")
            return
        }
        modelManager?.loadGridState(gridState: level.gridState)
        guard let unwindSegueIdentifier = unwindSegueIdentifier else {
            assertionFailure("Unwind segue identifier not assigned!")
            return
        }

        switch unwindSegueIdentifier {
        case Constants.levelSelectUnwindToMenuSegueIdentifier:
            performSegue(withIdentifier: Constants.levelSelectPlayGameSegueIndentifier,
                         sender: self)
        case Constants.levelSelectUnwindToLevelDesignSegueIdentifier:
            performSegue(withIdentifier: Constants.levelSelectUnwindToLevelDesignSegueIdentifier,
                         sender: self)
        default: assertionFailure("Should not reach here!")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 10.0,
                                     left: 10.0,
                                     bottom: 10.0,
                                     right: 10.0)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = Int(collectionView.bounds.width / 3.5)
        return CGSize(width: size, height: size)
    }
}
