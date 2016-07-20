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
    let upgradeManager = RZFUpgradeManager(appStoreID:"944415329")

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            upgradeManager.checkForNewUpdate()
        case (0, 1):
            upgradeManager.releaseNotesAccentColor = UIColor(red: 65.0/255.0, green: 180.0/255.0, blue: 270.0/255.0, alpha: 1.0)
            upgradeManager.fullScreenReleaseNotes = true
            upgradeManager.releaseNotesTitleFont = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
            upgradeManager.releaseNotesDoneFont = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
            upgradeManager.releaseNotesDoneBackgroundColor = UIColor.whiteColor()
            upgradeManager.releaseNotesDoneCornerRadius = 5.0
            upgradeManager.releaseNotesDoneHighlightAlpha = 0.5
            upgradeManager.releaseNotesDoneTitle = "Explore"

            upgradeManager.showNewReleaseNotes(true)
        case (0, 2):
            upgradeManager.releaseNotesAccentColor = nil
            upgradeManager.fullScreenReleaseNotes = false
            upgradeManager.releaseNotesTitleFont = nil
            upgradeManager.releaseNotesDoneFont = nil
            upgradeManager.releaseNotesDoneBackgroundColor = nil
            upgradeManager.releaseNotesDoneCornerRadius = 0.0
            upgradeManager.releaseNotesDoneHighlightAlpha = 1.0
            upgradeManager.releaseNotesDoneTitle = nil

            upgradeManager.showNewReleaseNotes(true)
        case (0, 3):
            upgradeManager.resetViewedState()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

