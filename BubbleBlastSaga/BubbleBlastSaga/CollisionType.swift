//
//  CollisionType.swift
//  GameEngine
//
//  Created by Yong Lin Han on 9/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

/// The different `CollisionType`s that can occur in the Physics simulation.
enum CollisionType {
    case circleWithCircle
    case circleWithTopOfEdgeLoop
    case circleWithLeftOfEdgeLoop
    case circleWithRightOfEdgeLoop
    case circleWithBottomOfEdgeLoop
}
