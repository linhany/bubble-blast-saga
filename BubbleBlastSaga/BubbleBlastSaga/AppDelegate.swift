//
//  AppDelegate.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 15/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var modelManager = ModelManager()
    var storageManager = StorageManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // We retrieve the first view controller from the navigation
        // controller and pass to it the instances.
        guard let menuViewController = window?.rootViewController as? MenuViewController else {
            fatalError("Root view controller not set correctly!")
        }

        menuViewController.modelManager = modelManager
        menuViewController.storageManager = storageManager

        return true
    }

}
