//
//  RoundedButton.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    private let borderWidth: CGFloat = 1.0
    private let proportionOfCornerRadius: CGFloat = 12.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtonProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpButtonProperties()
    }

    override func awakeFromNib() {
        setUpButtonProperties()
    }

    func setUpButtonProperties() {
        layer.cornerRadius = layer.frame.width / proportionOfCornerRadius
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = borderWidth
        setTitleColor(.lightGray, for: .focused)
        setTitleColor(.lightGray, for: .highlighted)
    }

    func markAsSelected() {
        layer.borderWidth = borderWidth
    }

    func unmark() {
        layer.borderWidth = 0
    }
}
