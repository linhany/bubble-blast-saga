//
//  BubbleType.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

/// Represents the possible bubble types that can be in the game grid.
/// Invariants that must hold when adding more bubble types:
/// - Case .empty must have the largest integer value.
/// - The integer values for the cases must be assigned in an ascending
/// order without any break in sequence, indicating the order they
/// should be cycled in. (Upon tap in level design view bubble grid).
/// - The palette button in storyboard corresponding to each bubble type 
/// should have its tag value set to be its bubble type's value.
enum BubbleType: Int {
    case normalRed = 1
    case normalOrange = 2
    case normalBlue = 3
    case normalGreen = 4
    case empty = 5
}
