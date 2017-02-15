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
		/**
		
		Tutor: magic number, coding style - 1 (cap at -5).
		
		*/
		
        layer.borderWidth = 5
    }

    /// Makes the border of this button invisible by
    /// resetting the border width back to zero.
    func hideBorder() {
        layer.borderWidth = 0
    }

    /// Shows a simple animation that represents a press of the button.
    func animatePress() {
        UIView.animate(
            withDuration: Constants.paletteAnimationDuration,
            animations: {
                self.transform =
                    CGAffineTransform(scaleX: CGFloat(Constants.paletteTransformScale),
                                      y: CGFloat(Constants.paletteTransformScale))
            },
            completion: { (_: Bool) in
                self.restorePress()
            })
    }

    /// Helper function for animatePress() to restore the button to its original size.
    private func restorePress() {
        UIView.animate(withDuration: Constants.paletteAnimationDuration,
                       animations: {
                       self.transform = CGAffineTransform.identity
        })
    }

    private func setUpBorderProperties() {
        layer.cornerRadius = frame.size.width / 2
        layer.borderWidth = 0
        layer.borderColor = UIColor.black.cgColor
    }

}
