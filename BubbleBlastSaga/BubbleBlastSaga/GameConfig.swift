//
//  GameConfig.swift
//  Bubble Blast Saga
//
//  Created by Yong Lin Han on 25/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// The GameConfig file provides the user settings for the game.
struct GameConfig {
    /// User adjustable options
    static var isCannonShotsLimited = false
    static var isTimed = false
    static var timeLimitMultiplier = TimeLimitMultiplier.easy
    static var cannonShotsMultiplier = CannonShotsMultiplier.easy

    static var cannonShots: Int {
        return cannonShotsBase * cannonShotsMultiplier.rawValue
    }

    /// The time limit in seconds.
    static var timeLimit: Int {
        return timeLimitBase * timeLimitMultiplier.rawValue
    }

    static var bubblesLeftBonus: Double {
        return bubbleLeftBonusBase / Double(cannonShotsMultiplier.rawValue * cannonShotsMultiplier.rawValue)
    }
    static var timeLeftBonus: Double {
        return timeLeftBonusBase / Double(timeLimitMultiplier.rawValue * timeLimitMultiplier.rawValue)
    }

    /// Base number of shots for the user.
    private static var cannonShotsBase = 40
    /// Base time limit for the user.
    private static var timeLimitBase = 20

    private static var bubbleLeftBonusBase = 90.0
    private static var timeLeftBonusBase = 100.0
}

/// Multipliers for number of shots before user loses.
enum CannonShotsMultiplier: Int {
    case easy = 3
    case medium = 2
    case hard = 1
}

/// Multipliers for TimeLimit to clear the level, in seconds.
enum TimeLimitMultiplier: Int {
    case easy = 3
    case medium = 2
    case hard = 1
}
