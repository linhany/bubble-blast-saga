//
//  BubbleGridViewDataSource.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The bubble grid view data source class.
/// Because we always start the bubble grid off empty, and
/// only change it upon user interaction/loading through
/// notifications from Model component, this class acts as
/// just a config class to set up the grid structure.
class BubbleGridViewDataSource: NSObject {

    fileprivate var isInLevelDesigner: Bool

    init(collectionView: UICollectionView, isInLevelDesigner: Bool) {
        self.isInLevelDesigner = isInLevelDesigner
        super.init()
        collectionView.dataSource = self
    }

}

// MARK: - UICollectionViewDataSource
extension BubbleGridViewDataSource: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isInLevelDesigner
                ? Constants.noOfRowsInGameGridInLevelDesigner
                : Constants.noOfRowsInGameGrid
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionIsEven = section % 2 == 0
        return sectionIsEven
            ? Constants.noOfColumnsInEvenRowOfGameGrid
            : Constants.noOfColumnsInOddRowOfGameGrid
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: Constants.bubbleGridCellReuseIdentifier,
            for: indexPath as IndexPath) as? BubbleGridCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        let width = collectionView.bounds.width
        // Shows border only if this collectionView is in level designer.
        cell.initImageView(gridWidth: width, isBorderShown: isInLevelDesigner)
        return cell
    }

}
