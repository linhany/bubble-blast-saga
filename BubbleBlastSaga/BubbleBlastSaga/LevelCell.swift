//
//  LevelCell.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {
    override func layoutSubviews() {
        layer.cornerRadius = layer.frame.size.width/16
    }
}
