//
//  LevelSelectViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class LevelSelectViewController: UIViewController {

    internal var modelManager: ModelManager?
    internal var storageManager: StorageManager?
    internal var levelNamesAndImages: [(String, UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let modelManager = modelManager,
              let storageManager = storageManager else {
            fatalError("Model/Storage reference not passed.")
        }
        levelNamesAndImages = storageManager.getLevelNamesAndImagesFromDocumentDirectory()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        return cell
    }

}

extension LevelSelectViewController: UICollectionViewDelegateFlowLayout {

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
