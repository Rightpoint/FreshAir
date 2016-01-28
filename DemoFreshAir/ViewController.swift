//
//  ViewController.swift
//  DemoFreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import FreshAir

class ViewController: UITableViewController {
    static let freshairURL = NSBundle.mainBundle().URLForResource("Examples/TestFeature", withExtension: "freshair")
    var upgradeManager = RZFUpgradeManager(remoteURL: freshairURL, currentVersion: "2.0")

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        upgradeManager.refreshUpgradeBundle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            upgradeManager.showUpgradePromptIfDesired()
        case (0, 1):
            upgradeManager.showReleaseNotesIfDesired()
        case (0, 2):
            upgradeManager.showReleaseNotes()
        case (0, 3):
            NSUserDefaults.standardUserDefaults().removeObjectForKey(RZFLastVersionOfReleaseNotesDisplayedKey)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(RZFLastVersionPromptedKey)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

