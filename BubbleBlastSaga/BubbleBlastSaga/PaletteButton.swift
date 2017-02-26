//
//  PaletteButton.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Custom view class for the UIButtons used in the palette
/// to keep track of user's selected bubble type.
class PaletteButton: UIButton {

    private let proportionOfCornerRadius: CGFloat = 2
    private let borderWidth: CGFloat = 5
    private let transformScaleX: CGFloat = 0.1
    private let transformScaleY: CGFloat = 0.1
    private let springDamping: CGFloat = 0.2
    private let springVelocity: CGFloat = 6.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBorderProperties()
    }

    override func awakeFromNib() {
        setUpBorderProperties()
    }

    /// Makes the border of this button visible by
    /// increasing the border width.
    func showBorder() {
        layer.borderWidth = borderWidth
    }

    /// Makes the border of this button invisible by
    /// resetting the border width back to zero.
    func hideBorder() {
        layer.borderWidth = 0
    }

    /// Shows a simple animation that represents a press of the button.
    func animatePress() {
        transform = CGAffineTransform(scaleX: transformScaleX, y: transformScaleY)

        UIView.animate(withDuration: Constants.paletteBubbleAnimationDuration,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: springVelocity,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
            },
                       completion: nil)
    }

    private func setUpBorderProperties() {
        layer.cornerRadius = frame.size.width / proportionOfCornerRadius
        layer.borderColor = UIColor.black.cgColor
    }

}
