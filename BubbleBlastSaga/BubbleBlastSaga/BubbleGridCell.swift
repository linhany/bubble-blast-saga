//
//  BubbleGridCell.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 24/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Custom view class for the bubble grid cells used in bubble grid.
class BubbleGridCell: UICollectionViewCell {

    /// The UIImageView that represents a game bubble being at that location.
    private var imageView: UIImageView?
    private var isBorderShown = true

    override func layoutSubviews() {
        layer.cornerRadius = frame.size.width / 2
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = isBorderShown ? 1 : 0
    }

    /// Initializer for image view size.
    func initImageView(gridWidth: CGFloat, isBorderShown: Bool) {
        let size = Int(gridWidth / CGFloat(Constants.noOfColumnsInEvenRowOfGameGrid))
        imageView =
            UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.isBorderShown = isBorderShown
    }

    /// Returns true if imageView for this cell is empty.
    var isEmpty: Bool {
        guard let imageView = imageView else {
            return true
        }
        return imageView.image == nil
    }

    /// Updates the image view by setting it to the associated image with the `bubbleType`.
    /// Sets the image view's image to nil if the `bubbleType` is empty.
    func updateImageView(with bubbleType: BubbleType) {
        guard let imageView = imageView else {
            return
        }
        switch bubbleType {
        case .normalRed: imageView.image = UIImage(named: Constants.redBubbleIdentifier)
        case .normalOrange: imageView.image = UIImage(named: Constants.orangeBubbleIdentifier)
        case .normalBlue: imageView.image = UIImage(named: Constants.blueBubbleIdentifier)
        case .normalGreen: imageView.image = UIImage(named: Constants.greenBubbleIdentifier)
        case .normalPurple: imageView.image = UIImage(named: Constants.purpleBubbleIdentifier)
        case .normalGray: imageView.image = UIImage(named: Constants.grayBubbleIdentifier)
        case .normalPink: imageView.image = UIImage(named: Constants.pinkBubbleIdentifier)
        case .bomb: imageView.image = UIImage(named: Constants.bombBubbleIdentifier)
        case .lightning: imageView.image = UIImage(named: Constants.lightningBubbleIdentifier)
        case .star: imageView.image = UIImage(named: Constants.starBubbleIdentifier)
        case .indestructible: imageView.image = UIImage(named: Constants.indestructibleBubbleIdentifier)
        case .empty: imageView.image = nil
        }
        contentView.addSubview(imageView)
    }

    /// Clears the image view by setting the image view's image to nil.
    func clearImageView() {
        guard let imageView = imageView else {
            return
        }
        imageView.image = nil
        contentView.addSubview(imageView)
    }
}
