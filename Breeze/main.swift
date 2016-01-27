//
//  main.swift
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation
import FreshAirMac
import CommandLine

enum BreezeError : ErrorType {
    case InvalidFilePath(path: String)
    case InvalidJSONFormat(path: String)
    case ManifestFileMissing(filename: String)
}

func updateManifestShaInBundle(path: String) throws {
    guard let bundleURL = NSURL(string: "file://\(path)"),
        let bundle = NSBundle(URL: bundleURL) else {
            throw BreezeError.InvalidFilePath(path: path)
    }
    let manifestURL = bundleURL.URLByAppendingPathComponent(NSURL.rzf_manifestFilename())
    guard let entries = try RZFManifestEntry.rzf_importURL(manifestURL) as? [RZFManifestEntry] else {
        throw BreezeError.InvalidJSONFormat(path: path)
    }

    let JSON: [AnyObject] = try entries.map { entry in
        entry.sha = entry.shaInBundle(bundle)
        if entry.sha == nil {
            throw BreezeError.ManifestFileMissing(filename: entry.filename)
        }
        return entry.jsonRepresentation()
    }

    let data = try NSJSONSerialization.dataWithJSONObject(JSON, options: [.PrettyPrinted])
    data.writeToURL(manifestURL, atomically: true)
}

func populateManifestForReleaseInBundle(path: String) throws {
    guard let bundleURL = NSURL(string: "file://\(path)") else {
        throw BreezeError.InvalidFilePath(path: path)
    }
    let manifestURL = bundleURL.URLByAppendingPathComponent(NSURL.rzf_manifestFilename())
    let releaseURL  = bundleURL.URLByAppendingPathComponent(NSURL.rzf_releaseFilename())

    guard let releaseNotes = try RZFReleaseNotes.rzf_importURL(releaseURL) as? RZFReleaseNotes else {
        throw BreezeError.InvalidJSONFormat(path: releaseURL.path!)
    }
    guard let entries = try RZFManifestEntry.rzf_importURL(manifestURL) as? [RZFManifestEntry] else {
        throw BreezeError.InvalidJSONFormat(path: manifestURL.path!)
    }
    for release in releaseNotes.releases as! [RZFRelease] {
        for feature in release.features as! [RZFFeature] {
            // Check for key.png, key@2x.png, key@3x.png
            // In Localization, check for key.title, key.description
        }
    }
}


let cli = CommandLine()
let bundle = StringOption(shortFlag: "b", longFlag: "bundle", helpMessage: "Path to the freshair bundle.")
let sha = BoolOption(shortFlag: "s", longFlag: "sha",  helpMessage: "Calculate all of the sha values in the manifest.")
let release = BoolOption(shortFlag: "r", longFlag: "release",  helpMessage: "Update the manifest with the release file.")

cli.addOptions(bundle, sha, release)

do {
    try cli.parse()
    let path = bundle.value ?? "./"
    if release.wasSet {
        try populateManifestForReleaseInBundle(path)
    }
    if sha.wasSet {
        try updateManifestShaInBundle(path)
    }
    if !release.wasSet && !sha.wasSet {
        throw CommandLine.ParseError.MissingRequiredOptions([sha, release])
    }
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}


