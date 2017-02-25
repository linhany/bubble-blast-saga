//
//  LightningImageView.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class LightningImageView: UIImageView {

    private var lightningImages: [UIImage] = []

    override func awakeFromNib() {
        setUpLightningImages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLightningImages()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLightningImages()
    }

    private func setUpLightningImages() {
        let imagePrefix = "lightning_"
        let imageSuffixes = ["01", "02", "03", "04", "05", "06", "07", "08"]
        for suffix in imageSuffixes {
            guard let lightningImage = UIImage(named: imagePrefix + suffix) else {
                fatalError("Lightning images not found!")
            }
            lightningImages.append(lightningImage)
        }
    }

    func animateLightningRemoval() {
        animationImages = lightningImages
        animationDuration = Constants.lightningBubbleAnimationDuration
        animationRepeatCount = 1
        startAnimating()
        Timer.scheduledTimer(timeInterval: Constants.lightningBubbleAnimationDuration,
                             target: self,
                             selector: #selector(self.removeFromSuperview),
                             userInfo: nil,
                             repeats: false)
    }

}
