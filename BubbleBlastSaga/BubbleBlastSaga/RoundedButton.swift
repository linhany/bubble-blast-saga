//
//  RoundedButton.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpButtonProperties()
    }

    override func awakeFromNib() {
        setUpButtonProperties()
    }

    func setUpButtonProperties() {
        layer.cornerRadius = layer.frame.width/12
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        setTitleColor(.lightGray, for: .focused)
        setTitleColor(.lightGray, for: .highlighted)
    }
}
