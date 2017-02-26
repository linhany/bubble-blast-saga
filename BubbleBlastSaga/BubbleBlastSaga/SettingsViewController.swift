//
//  SettingsViewController.swift
//  BubbleBlastSaga
//
//  Created by Yong Lin Han on 26/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var limitedShotsSwitch: UISwitch!
    @IBOutlet var limitedTimeSwitch: UISwitch!
    @IBOutlet var limitedShotsOptions: UIStackView!
    @IBOutlet var limitedTimeOptions: UIStackView!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        setUpLimitedShotsSwitch()
        setUpLimitedTimeSwitch()
        markCurrentlySelectedLimitedShotOption()
        markCurrentlySelectedLimitedTimeOption()
    }

    @IBAction func limitedShotsButtonPressed(_ sender: UIButton) {
        let value = sender.tag
        guard let multiplier = CannonShotsMultiplier(rawValue: value) else {
            fatalError("Button not assigned the correct tag.")
        }
        GameConfig.cannonShotsMultiplier = multiplier
        markCurrentlySelectedLimitedShotOption()
    }

    @IBAction func limitedTimeButtonPressed(_ sender: UIButton) {
        let value = sender.tag
        guard let multiplier = TimeLimitMultiplier(rawValue: value) else {
            fatalError("Button not assigned the correct tag.")
        }
        GameConfig.timeLimitMultiplier = multiplier
        markCurrentlySelectedLimitedTimeOption()
    }

    private func setUpLimitedShotsSwitch() {
        limitedShotsSwitch.isOn = GameConfig.isCannonShotsLimited
        limitedShotsSwitch.addTarget(self, action: #selector(limitedShotsSwitchChanged), for: .valueChanged)
    }

    private func setUpLimitedTimeSwitch() {
        limitedTimeSwitch.isOn = GameConfig.isTimed
        limitedTimeSwitch.addTarget(self, action: #selector(limitedTimeSwitchChanged), for: .valueChanged)
    }

    private func markCurrentlySelectedLimitedShotOption() {
        let tag = GameConfig.cannonShotsMultiplier.rawValue
        for subview in limitedShotsOptions.subviews {
            guard let button = subview as? RoundedButton else {
                fatalError("Not assigned correct class.")
            }
            if button.tag == tag {
                button.markAsSelected()
            } else {
                button.unmark()
            }
        }
    }

    private func markCurrentlySelectedLimitedTimeOption() {
        let tag = GameConfig.timeLimitMultiplier.rawValue
        for subview in limitedTimeOptions.subviews {
            guard let button = subview as? RoundedButton else {
                fatalError("Not assigned correct class.")
            }
            if button.tag == tag {
                button.markAsSelected()
            } else {
                button.unmark()
            }
        }
    }

    @objc private func limitedShotsSwitchChanged() {
        GameConfig.isCannonShotsLimited = limitedShotsSwitch.isOn
    }

    @objc private func limitedTimeSwitchChanged() {
        GameConfig.isTimed = limitedTimeSwitch.isOn
    }

}
