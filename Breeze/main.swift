//
//  main.swift
//  Breeze
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation
import FreshAirMac

private struct Parameters {
    static let inputPath = "."
    static let manifestFileName = "manifest.json"
}

let fileManager = NSFileManager.defaultManager()
let manifestPath = "./\(NSURL.rzf_manifestFilename())"
if fileManager.fileExistsAtPath(manifestPath) {
    
}
else {

}

let sha = RZFFileHash.sha1HashOfFileAtPath("FreshAirMac.framework/Versions/A/Headers/FreshAirMac.h")
