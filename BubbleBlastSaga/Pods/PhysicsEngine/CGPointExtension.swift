//
//  CGPointExtension.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//  Credits: https://www.raywenderlich.com/145318/spritekit-swift-3-tutorial-beginners

import UIKit

/// Helpers for CGPoint and extension.
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

public extension CGPoint {
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }

    public func normalized() -> CGPoint {
        return self / length()
    }
}
