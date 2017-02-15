//
//  Constants.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 31/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

/// The constants used in the application.
struct Constants {

    static let noOfRowsInGameGrid = 12
    static let noOfColumnsInEvenRowOfGameGrid = 12
    static let noOfColumnsInOddRowOfGameGrid = noOfColumnsInEvenRowOfGameGrid - 1

    static let bubbleGridCellReuseIdentifer = "bubbleGridCell"
    static let loadLevelsCellIdentifer = "LevelCell"
    static let loadLevelsSegueIdentifier = "ShowLoadLevelsSegue"
    static let redBubbleIdentifer = "bubble-red"
    static let orangeBubbleIdentifer = "bubble-orange"
    static let blueBubbleIdentifer = "bubble-blue"
    static let greenBubbleIdentifer = "bubble-green"

    static let notifyBubbleGridUpdated = "Bubble grid updated."
    static let notifyPosition = "Position in grid"
    static let notifyBubbleType = "Bubble type"

    static let feedbackLevelSavingCancelled = "SAVING CANCELLED!"
    static let feedbackLevelNameRequired = "LEVEL NAME REQUIRED!"
    static let feedbackLevelSavingSuccessful = "LEVEL SAVED!"
    static let feedbackLevelSavingUnsuccessful = "LEVEL WAS NOT SAVED!"
    static let feedbackLevelReset = "LEVEL RESET!"
    static let feedbackLevelLoadSuccessful = "LEVEL LOADED!"
    static let feedbackLevelLoadUnsuccessful = "LEVEL WAS NOT LOADED!"
    static let feedbackLevelDelete = "LEVEL DELETED!"
    static let feedbackTimer = 1.5

    static let emptyString = ""

    static let loadLevelTableHeader = "Levels"

    static let alertSaveLevelTitle = "Save Level"
    static let alertSaveLevelMessage = "Give your level a cool name!"
    static let alertSaveLevelTextPlaceholder = "Your level name here.."
    static let alertResetLevelTitle = "Reset Level"
    static let alertDeleteLevelTitle = "Delete Level"
    static let alertConfirmTitle = "Confirm"
    static let alertCancelTitle = "Cancel"
    static let alertIrreversibleWarning = "This is irreversible!"

    static let paletteAnimationDuration = 0.3
    static let paletteTransformScale = 0.8
}
