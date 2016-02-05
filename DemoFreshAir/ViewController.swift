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
    static let freshairURL = NSBundle.mainBundle().URLForResource("Examples/Test", withExtension: "releaseNotes")
    let upgradeManager = RZFUpgradeManager(appStoreID:"944415329")


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        upgradeManager.bundle = NSBundle(URL: self.dynamicType.freshairURL!)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            upgradeManager.checkForNewUpdate()
        case (0, 1):
            upgradeManager.showNewReleaseNotes()
        case (0, 2):
            upgradeManager.resetViewedState()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

