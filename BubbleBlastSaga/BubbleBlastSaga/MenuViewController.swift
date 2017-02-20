//
//  MenuViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    internal var modelManager: ModelManager?
    internal var storageManager: StorageManager?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backToMenuViewController(segue: UIStoryboardSegue) {
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let levelSelectVC = segue.destination as? LevelSelectViewController {
            levelSelectVC.modelManager = modelManager
            levelSelectVC.storageManager = storageManager
            levelSelectVC.unwindSegueIdentifier = Constants.levelSelectUnwindToMenuSegueIdentifier
        } else if let levelDesignVC = segue.destination as? LevelDesignViewController {
            levelDesignVC.modelManager = modelManager
            levelDesignVC.storageManager = storageManager
        }

    }

}
