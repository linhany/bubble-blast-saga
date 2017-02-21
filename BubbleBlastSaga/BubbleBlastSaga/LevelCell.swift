//
//  LevelCell.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {
    var textLabel: UILabel?
    var imageView: UIImageView?

    override func layoutSubviews() {
        layer.cornerRadius = layer.frame.size.width/16
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
        layer.borderWidth = 5
    }

    func hideBorder() {
        layer.borderWidth = 0
    }

    private func initTextLabelProperties() {
        let textLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height - frame.size.height/5, width: frame.size.width, height: frame.size.height/5))
        textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.black
        contentView.addSubview(textLabel)

        self.textLabel = textLabel
    }

    private func initImageViewProperties() {
        let imageView = UIImageView()
        imageView.alpha = 0.25
        backgroundView = imageView
        self.imageView = imageView
    }

}
