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

    init(collectionView: UICollectionView) {
        super.init()
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDataSource
extension BubbleGridViewDataSource: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.noOfRowsInGameGrid-1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionIsEven = section % 2 == 0
        return sectionIsEven
            ? Constants.noOfColumnsInEvenRowOfGameGrid
            : Constants.noOfColumnsInOddRowOfGameGrid
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.bubbleGridCellReuseIdentifier,
            for: indexPath as IndexPath) as? BubbleGridCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        let width = collectionView.bounds.width
        cell.initImageView(gridWidth: width, isBorderHidden: false)
        return cell
    }

}
