//
//  BombImageView.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class BombImageView: UIImageView {

    private var bombImages: [UIImage] = []

    override func awakeFromNib() {
        setUpBombImages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBombImages()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBombImages()
    }

    private func setUpBombImages() {
        let imagePrefix = Constants.bombImagePrefix
        let imageSuffixes = Constants.bombImageSuffixes
        for suffix in imageSuffixes {
            guard let bombImage = UIImage(named: imagePrefix + suffix) else {
                fatalError("Bomb images not found!")
            }
            bombImages.append(bombImage)
        }
    }

    func animateBombRemoval() {
        animationImages = bombImages
        animationDuration = Constants.bombBubbleAnimationDuration
        animationRepeatCount = 1
        startAnimating()
        Timer.scheduledTimer(timeInterval: Constants.lightningBubbleAnimationDuration,
                             target: self,
                             selector: #selector(self.removeFromSuperview),
                             userInfo: nil,
                             repeats: false)
    }

}
