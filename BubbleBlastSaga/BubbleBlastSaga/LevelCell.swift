//
//  LevelCell.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The level cell represents a level in the level selection screen.
/// It has an imageView as a preview of that level, and a text label that displays
/// the level name.
class LevelCell: UICollectionViewCell {
    /// The proportion of corner radius to divide by.
    private let proportionOfCornerRadius: CGFloat = 16
    private let borderWidth: CGFloat = 5
    private let alphaLevel: CGFloat = 0.25
    internal var textLabel: UILabel?
    internal var imageView: UIImageView?

    override func layoutSubviews() {
        layer.cornerRadius = layer.frame.size.width / proportionOfCornerRadius
        layer.borderColor = UIColor.red.cgColor
    }

    override func prepareForReuse() {
        textLabel?.text = nil
        imageView?.image = nil
    }

    func setTitle(_ title: String) {
        initTextLabelProperties()
        textLabel?.text = title
    }

    func setPreview(_ image: UIImage) {
        initImageViewProperties()
        imageView?.image = image
    }

    func showRedBorder() {
        layer.borderWidth = borderWidth
    }

    func hideBorder() {
        layer.borderWidth = 0
    }

    private func initTextLabelProperties() {
        let textLabel = UILabel(frame: CGRect(x: 0,
                                              y: frame.size.height - frame.size.height/borderWidth,
                                              width: frame.size.width,
                                              height: frame.size.height/borderWidth))
        textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.black
        contentView.addSubview(textLabel)

        self.textLabel = textLabel
    }

    private func initImageViewProperties() {
        let imageView = UIImageView()
        imageView.alpha = alphaLevel
        backgroundView = imageView
        self.imageView = imageView
    }

}
