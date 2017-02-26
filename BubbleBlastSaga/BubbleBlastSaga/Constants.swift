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
    static let noOfRowsInGameGridInLevelDesigner = noOfRowsInGameGrid-1
    static let noOfColumnsInEvenRowOfGameGrid = 12
    static let noOfColumnsInOddRowOfGameGrid = noOfColumnsInEvenRowOfGameGrid - 1

    static let normalBubbleScore = 10
    static let lightningBubbleScore = 5
    static let bombBubbleScore = 0
    static let starBubbleScore = 7
    static let indestructibleBubbleScore = 15
    static let winBonusMultiplier = 2

    static let noOfRunsBeforeRendering = 10

    static let gameBubbleCollisionAdjustedPercentage = 0.85
    static let gameLoopFramesPerSecond = 60
    static let gameBubbleClusterLimit = 3

    static let reverseDirectionMultiplier = -1

    static let leftFireAngleBound = -1.18
    static let rightFireAngleBound = 1.18

    static let noOfNormalBubbleTypes = 7

    static let gameProjectileVelocityMultiplier = 2

    static let bombBubbleExplosionRadiusMultiplier = 3
    static let snapBehaviorDamping = 0.3
    static let snapBehaviorElasticity = 1.4

    static let proportionOfCellToOffset = -8

    static let neighbourEvenRowOffsets = [(-1, -1), (1, -1), (0, -1), (-1, 0), (1, 0), (0, 1)]
    static let neighbourOddRowOffsets = [(-1, 1), (1, 1), (0, -1), (-1, 0), (1, 0), (0, 1)]

    static let bubbleGridCellReuseIdentifier = "bubbleGridCell"
    static let levelCellReuseIdentifier = "levelCell"
    static let loadLevelsCellIdentifier = "LevelCell"
    static let loadLevelsSegueIdentifier = "ShowLoadLevelsSegue"
    static let startGameLevelSegueIdentifier = "StartGameLevelSegue"
    static let levelSelectPlayGameSegueIdentifier = "LevelSelectPlayGameSegue"
    static let gameUnwindToLevelDesignSegueIdentifier = "GameUnwindToLevelDesignSegue"
    static let gameUnwindToLevelSelectSegueIdentifier = "GameUnwindToLevelSelectSegue"
    static let levelSelectUnwindToLevelDesignSegueIdentifier = "LevelSelectUnwindToLevelDesignSegue"
    static let levelSelectUnwindToMenuSegueIdentifier = "LevelSelectUnwindToMenuSegue"
    static let menuToLevelSelectSegueIdentifier = "MenuToLevelSelectSegue"
    static let menuToLevelDesignSegueIdentifier = "MenuToLevelDesignSegue"
    static let menuToSettingsSegueIdentifier = "MenuToSettingsSegue"
    static let levelDesignToLevelSelectSegueIdentifier = "LevelDesignToLevelSelectSegue"

    static let endGameLoseText = "YOU LOST! :("
    static let endGameWinText = "YOU WON! :)"
    static let endGameDefaultWinText = "DEFAULT WIN :O"

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
    static let gameBubbleIdentifier = "GameBubble"

    static let cannonImagePrefix = "cannon_"
    static let cannonImageSuffixes = ["01", "02", "03", "04", "05", "06",
                         "07", "08", "09", "10", "11", "12"]
    static let cannonFireAnimationDuration = 0.3
    static let bubbleBurstImagePrefix = "bubble-burst_"
    static let bubbleBurstImageSuffixes = ["01", "02", "03", "04"]
    static let lightningImagePrefix = "lightning_"
    static let lightningImageSuffixes = ["01", "02", "03", "04", "05", "06", "07", "08"]
    static let bombImagePrefix = "bomb_"
    static let bombImageSuffixes = ["01", "02", "03", "04", "05", "06", "07",
                                    "08", "09", "10", "11", "12", "13", "14"]

    static let messageGamePlayScore = "Gameplay Score: "
    static let messageShotsLeft = "Shots Left: "
    static let messageShotsLeftBonus = "Shots Left Bonus: +"
    static let messageTimeLeft = "Time Left: "
    static let messageTimeSeconds = " seconds"
    static let messageTimeLeftBonus = "Time Left Bonus: +"
    static let messageBubblesFired = "Bubbles Fired: "
    static let messagePlayTime = "Play Time: "
    static let messageWinBonus = "Win Bonus: x2"
    static let messageFinalScore = "Final Score: "

    static let endGameScreenFontSize = 30

    static let notifyBubbleGridUpdated = "Bubble grid updated."
    static let notifyPosition = "Position in grid"
    static let notifyBubbleType = "Bubble type"
    static let notifyMovingGameObject = "Game object moving."
    static let notifyRemovedGameObject = "Game object removed."

    static let notifyLoadingCannonGameBubble = "Game bubble loaded into cannon!"
    static let notifyNewlySnappedGameBubble = "Game bubble snapped into grid!"
    static let notifyRemoveDisconnectedGameBubble = "Game bubble disconnected!"
    static let notifyRemoveClusteredGameBubble = "Game bubble clustered!"
    static let notifyRemoveLightningBubble = "Lightning bubble zapped!"
    static let notifyRemoveBombBubble = "Bomb bubble exploded!"
    static let notifyBubbleCountDecrease = "Bubble generated! Count decreased."

    static let loadingBubbleAnimationDuration = 0.2
    static let fallingBubbleAnimationDuration = 1.5
    static let burstingBubbleAnimationDuration = 0.4
    static let lightningBubbleAnimationDuration = 0.4
    static let bombBubbleAnimationDuration = 0.4
    static let paletteBubbleAnimationDuration = 2.0

    static let feedbackLevelSavingCancelled = "SAVING CANCELLED!"
    static let feedbackLevelNameRequired = "LEVEL NAME IS NOT VALID!"
    static let feedbackLevelSavingSuccessful = "LEVEL SAVED!"
    static let feedbackLevelSavingUnsuccessful = "LEVEL WAS NOT SAVED!"
    static let feedbackLevelReset = "LEVEL RESET!"
    static let feedbackLevelResetAlreadyEmpty = "LEVEL IS ALREADY EMPTY!"
    static let feedbackLevelLoadSuccessful = "LEVEL LOADED!"
    static let feedbackLevelLoadUnsuccessful = "LEVEL WAS NOT LOADED!"
    static let feedbackLevelDelete = "LEVEL DELETED!"
    static let feedbackTimer = 1.5

    static let levelSelectionNoOfLevelsInARow = 3
    static let levelSelectionCellSizeProportion = 3.28
    static let levelSelectionCellInset = 10.0
    static let levelSelectionDeleteButtonTitle = "Delete"
    static let levelSelectionDeleteModeDeleteButtonTitle = "Confirm"
    static let levelSelectionHeaderText = "Level selection"
    static let levelSelectionDeleteModeHeaderText = "Deletion is permanent! Mark levels to delete"

    static let emptyString = ""

    static let levelNameCharacterCountLimit = 25

    static let alertSaveLevelTitle = "Save Level"
    static let alertSaveLevelMessage = "Level names must be between 1 to 25 characters."
    static let alertSaveLevelTextPlaceholder = "Your level name here.."
    static let alertResetLevelTitle = "Reset Level"
    static let alertDeleteLevelTitle = "Delete Level"
    static let alertConfirmTitle = "Confirm"
    static let alertCancelTitle = "Cancel"
    static let alertIrreversibleWarning = "This is irreversible!"

    static let paletteAnimationDuration = 0.3
    static let paletteTransformScale = 0.8
}
