//
//  MenuViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// The Controller responsible for the main menu of our Bubble Game.
/// This is the first ViewController in our app and therefore receives
/// references of Model and Storage components from `AppDelegate`, to pass
/// them through segues to other ViewControllers.
class MenuViewController: UIViewController {

    /// The manager for Model component of the app.
    internal var modelManager: ModelManager?

    /// The manager for Storage component of the app.
    internal var storageManager: StorageManager?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Navigation

    @IBAction func backToMenuViewController(segue: UIStoryboardSegue) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let levelSelectVC = segue.destination as? LevelSelectViewController {
            levelSelectVC.modelManager = modelManager
            levelSelectVC.storageManager = storageManager
            levelSelectVC.unwindSegueIdentifier = Constants.levelSelectUnwindToMenuSegueIdentifier
        } else if let levelDesignVC = segue.destination as? LevelDesignViewController {
            modelManager?.resetGridState()
            levelDesignVC.modelManager = modelManager
            levelDesignVC.storageManager = storageManager
        }

    }

}
