//
//  CannonImageView.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 15/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class CannonImageView: UIImageView {
    private var cannonImages: [UIImage] = []

    override func awakeFromNib() {
        setUpCannonImages()
        setUpCannonFireAnimation()
        setUpCannonRotation()
    }

    func rotateCannon(offset: CGPoint) {
        let angle = Double(atan2(offset.x, -offset.y))

        guard angle > Constants.leftFireAngleBound &&
            angle < Constants.rightFireAngleBound else {
                return
        }
        transform = CGAffineTransform.identity
        transform =
            CGAffineTransform(rotationAngle: CGFloat(angle))
    }

    private func setUpCannonImages() {
        let imagePrefix = "cannon_"
        let imageSuffixes = ["01", "02", "03", "04", "05", "06",
                             "07", "08", "09", "10", "11", "12"]
        for suffix in imageSuffixes {
            guard let cannonImage = UIImage(named: imagePrefix + suffix) else {
                fatalError("Cannon images not found!")
            }
            cannonImages.append(cannonImage)
        }
        self.image = cannonImages.first
    }

    private func setUpCannonFireAnimation() {
        animationImages = cannonImages
        animationDuration = 0.3
        animationRepeatCount = 1
    }

    private func setUpCannonRotation() {
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
    }
}
