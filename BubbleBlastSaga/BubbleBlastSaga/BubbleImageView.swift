//
//  BubbleImageView.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class BubbleImageView: UIImageView {

    private var bubbleBurstImages: [UIImage] = []

    override func awakeFromNib() {
        setUpBubbleBurstImages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBubbleBurstImages()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        setUpBubbleBurstImages()
    }

    private func setUpBubbleBurstImages() {
        let imagePrefix = "bubble-burst_"
        let imageSuffixes = ["01", "02", "03", "04"]
        for suffix in imageSuffixes {
            guard let bubbleBurstImage = UIImage(named: imagePrefix + suffix) else {
                fatalError("Bubble burst images not found!")
            }
            bubbleBurstImages.append(bubbleBurstImage)
        }
    }

    func animateBurstRemoval() {
        image = nil
        animationImages = bubbleBurstImages
        animationDuration = Constants.burstingBubbleAnimationDuration
        animationRepeatCount = 1
        startAnimating()
        Timer.scheduledTimer(timeInterval: Constants.burstingBubbleAnimationDuration,
                             target: self,
                             selector: #selector(self.removeFromSuperview),
                             userInfo: nil,
                             repeats: false)
    }

}
