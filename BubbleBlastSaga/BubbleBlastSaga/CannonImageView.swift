//
//  CannonImageView.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 15/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class CannonImageView: UIImageView {
    private let anchorPointX = 0.5
    private let anchorPointY = 0.65
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
        let imagePrefix = Constants.cannonImagePrefix
        let imageSuffixes = Constants.cannonImageSuffixes
        for suffix in imageSuffixes {
            guard let cannonImage = UIImage(named: imagePrefix + suffix) else {
                fatalError("Cannon images not found!")
            }
            cannonImages.append(cannonImage)
        }
        image = cannonImages.first
    }

    private func setUpCannonFireAnimation() {
        animationImages = cannonImages
        animationDuration = Constants.cannonFireAnimationDuration
        animationRepeatCount = 1
    }

    private func setUpCannonRotation() {
        layer.anchorPoint = CGPoint(x: anchorPointX, y: anchorPointY)
    }
}
