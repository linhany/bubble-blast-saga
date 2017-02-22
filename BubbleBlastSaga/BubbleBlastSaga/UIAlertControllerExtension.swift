//
//  UIAlertControllerExtension.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Extensions for UIAlertController that returns customised alerts for the application.
extension UIAlertController {

    /// Returns an alert for saving level.
    /// Includes a text field, confirm, and cancel option.
    static func alertForSaveLevel(closure: @escaping
        (_ isSaveConfirmed: Bool, _ userInput: String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: Constants.alertSaveLevelTitle,
            message: Constants.alertSaveLevelMessage,
            preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: Constants.alertConfirmTitle,
                                          style: .default) { (_: UIAlertAction) in
            guard let text = alertController.textFields?.first?.text else {
                return
            }
            closure(true, text)
        }
        let cancelAction = UIAlertAction(title: Constants.alertCancelTitle, style: .cancel) { (_: UIAlertAction) in
            closure(false, Constants.emptyString)
        }
        alertController.addTextField { (textField) in
            textField.placeholder = Constants.alertSaveLevelTextPlaceholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    /// Returns an alert for resetting level.
    /// Includes a confirm and cancel option.
    static func alertForResetLevel(closure: @escaping
        (_ isResetConfirmed: Bool) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: Constants.alertResetLevelTitle,
            message: Constants.alertIrreversibleWarning,
            preferredStyle: UIAlertControllerStyle.alert)

        let confirmAction = UIAlertAction(title: Constants.alertConfirmTitle, style: .default) { (_: UIAlertAction) in
            closure(true)
        }
        let cancelAction = UIAlertAction(title: Constants.alertCancelTitle, style: .cancel) { (_:UIAlertAction) in
            closure(false)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    /// Returns an alert for deleting level.
    /// Includes a confirm and cancel option.
    static func alertForDeleteLevel(closure: @escaping
        (_ isDeleteConfirmed: Bool) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: Constants.alertDeleteLevelTitle,
            message: Constants.alertIrreversibleWarning,
            preferredStyle: UIAlertControllerStyle.alert)

        let confirmAction = UIAlertAction(title: Constants.alertConfirmTitle, style: .default) { (_: UIAlertAction) in
            closure(true)
        }
        let cancelAction = UIAlertAction(title: Constants.alertCancelTitle, style: .cancel) { (_:UIAlertAction) in
            closure(false)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        return alertController
    }

}
