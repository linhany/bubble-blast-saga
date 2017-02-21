//
//  Constants.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 31/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

/// The constants used in the application.
struct Constants {

    static let noOfRowsInGameGrid = 14
    static let noOfColumnsInEvenRowOfGameGrid = 12
    static let noOfColumnsInOddRowOfGameGrid = noOfColumnsInEvenRowOfGameGrid - 1

    static let noOfRunsBeforeRendering = 20

    static let gameBubbleCollisionAdjustedPercentage = 0.85
    static let gameLoopFramesPerSecond = 60
    static let gameBubbleClusterLimit = 3

    static let reverseDirectionMultiplier = -1

    static let leftFireAngleBound = -1.18
    static let rightFireAngleBound = 1.18

    static let noOfNormalBubbleTypes = 7

    static let bubbleGridCellReuseIdentifier = "bubbleGridCell"
    static let levelCellReuseIdentifier = "levelCell"
    static let loadLevelsCellIdentifier = "LevelCell"
    static let loadLevelsSegueIdentifier = "ShowLoadLevelsSegue"
    static let startGameLevelSegueIndentifier = "StartGameLevelSegue"
    static let levelSelectPlayGameSegueIndentifier = "LevelSelectPlayGameSegue"
    static let gameUnwindToLevelDesignSegueIdentifier = "GameUnwindToLevelDesignSegue"
    static let gameUnwindToLevelSelectSegueIdentifier = "GameUnwindToLevelSelectSegue"
    static let levelSelectUnwindToLevelDesignSegueIdentifier = "LevelSelectUnwindToLevelDesignSegue"
    static let levelSelectUnwindToMenuSegueIdentifier = "LevelSelectUnwindToMenuSegue"
    static let menuToLevelSelectSegueIdentifier = "MenuToLevelSelectSegue"
    static let menuToLevelDesignSegueIdentifier = "MenuToLevelDesignSegue"
    static let levelDesignToLevelSelectSegueIdentifier = "LevelDesignToLevelSelectSegue"

    static let endGameLoseText = "YOU LOST! :("
    static let endGameWinText = "YOU WON! :)"

    static let redBubbleIdentifier = "bubble-red"
    static let orangeBubbleIdentifier = "bubble-orange"
    static let blueBubbleIdentifier = "bubble-blue"
    static let greenBubbleIdentifier = "bubble-green"
    static let purpleBubbleIdentifier = "bubble-purple"
    static let grayBubbleIdentifier = "bubble-gray"
    static let pinkBubbleIdentifier = "bubble-pink"
    static let bombBubbleIdentifier = "bubble-bomb"
    static let lightningBubbleIdentifier = "bubble-lightning"
    static let starBubbleIdentifier = "bubble-star"
    static let indestructibleBubbleIdentifier = "bubble-indestructible"
    static let gameObjectIdentifier = "GameObject"

    static let notifyBubbleGridUpdated = "Bubble grid updated."
    static let notifyPosition = "Position in grid"
    static let notifyBubbleType = "Bubble type"
    static let notifyMovingGameObject = "Game object moving."
    static let notifyRemovedGameObject = "Game object removed."

    static let notifyLoadingCannonGameBubble = "Game bubble loaded into cannon!"
    static let notifyNewlySnappedGameBubble = "Game bubble snapped into grid!"
    static let notifyRemoveDisconnectedGameBubble = "Game bubble disconnected!"
    static let notifyRemoveClusteredGameBubble = "Game bubble clustered!"
    static let loadingBubbleAnimationDuration = 0.2
    static let fallingBubbleAnimationDuration = 1.5

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
