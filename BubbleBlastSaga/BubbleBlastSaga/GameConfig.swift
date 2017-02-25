//
//  GameConfig.swift
//  Bubble Blast Saga
//
//  Created by Yong Lin Han on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

struct GameConfig {
    static var isCannonShotsLimited = true
    static var isTimed = true

    static var cannonShots = cannonShotsBase * cannonShotsMultiplier.rawValue

    /// The time limit in seconds.
    static var timeLimit = Int(timeLimitBase * timeLimitMultiplier.rawValue)

    /// Let user set these.
    static var timeLimitMultiplier = TimeLimitMultiplier.easy
    static var cannonShotsMultiplier = CannonShotsMultiplier.easy

    static var bubblesLeftBonus = 90 / cannonShotsMultiplier.rawValue
    static var timeLeftBonus = 100 / timeLimitMultiplier.rawValue

    /// Base number of shots for the user.
    private static var cannonShotsBase = 20
    /// Base time limit for the user.
    private static var timeLimitBase = 30.0
}

/// Multipliers for number of shots before user loses.
enum CannonShotsMultiplier: Int {
    case easy = 3
    case medium = 2
    case hard = 1
}

/// Multipliers for TimeLimit to clear the level, in seconds.
enum TimeLimitMultiplier: Double {
    case easy = 2
    case medium = 1.5
    case hard = 1
}
