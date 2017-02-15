//
//  BubbleGridViewDelegate.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The bubble grid view delegate class.
/// Customises the grid structure by calculating the appropriate
/// edge insets and size of each cell.
class BubbleGridViewDelegate: NSObject {

    init(collectionView: UICollectionView) {
        super.init()
        collectionView.delegate = self
    }
}

extension BubbleGridViewDelegate: UICollectionViewDelegateFlowLayout {

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

		/**
		
		Tutor: magic number, coding style - 2.
		
		*/
		
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
