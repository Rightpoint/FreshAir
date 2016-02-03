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
        let result = entry.jsonRepresentation()
        return result
    }

    let data = try NSJSONSerialization.dataWithJSONObject(JSON, options: [.PrettyPrinted])
    data.writeToURL(manifestURL, atomically: true)
}

func populateManifestForReleaseInBundle(path: String, featureExpansions: [ExpansionSet]) throws {
    guard let bundleURL = NSURL(string: "file://\(path)") else {
        throw BreezeError.InvalidFilePath(path: path)
    }
    let releaseURL  = bundleURL.URLByAppendingPathComponent(NSURL.rzf_releaseFilename())

    guard let releaseNotes = try RZFReleaseNotes.rzf_importURL(releaseURL) as? RZFReleaseNotes else {
        throw BreezeError.InvalidJSONFormat(path: releaseURL.path!)
    }

    print("# Copy and Paste the following commands")
    for release in releaseNotes.releases {
        for feature in release.features {
            let paths = performExpansions(featureExpansions, onPath: feature.key)
            let commands = paths.map() { "touch \($0)" }
            print(commands.joinWithSeparator("\n"))
        }
    }
}

let cli = CommandLine()
let bundleOpt = StringOption(shortFlag: "b", longFlag: "bundle", helpMessage: "Path to the freshair bundle.")
let shaOpt = BoolOption(shortFlag: "s", longFlag: "sha",  helpMessage: "Calculate all of the sha values in the manifest.")

let releaseOpt = BoolOption(shortFlag: "i", longFlag: "images",  helpMessage: "Generate images for the flags 'languages', 'resolution', and 'device'")
let platformOpt = EnumOption<Platform>(shortFlag: "p", longFlag: "platform",  helpMessage: "The platform to generate for. apple or android.")
let languageOpt = MultiStringOption(longFlag: "languages",  helpMessage: "Generate files for all of the languages")
let resolutionOpt = MultiStringOption(longFlag: "resolution",  helpMessage: "Generate files for all of the resolutions")
let deviceOpt = MultiStringOption(longFlag: "device",  helpMessage: "Generate files for all of the devices")

cli.addOptions(bundleOpt, shaOpt, releaseOpt, platformOpt, languageOpt, resolutionOpt, deviceOpt)

do {
    try cli.parse()
    let path = bundleOpt.value ?? "./"
    if releaseOpt.wasSet {
        let platform = platformOpt.value ?? .Apple
        let localeStrings = languageOpt.value ?? []
        let resolutionStrings = resolutionOpt.value ?? []
        let deviceStrings = deviceOpt.value ?? []

        var expansions: [ExpansionSet] = Array()
        expansions.append([AssetType.PNG])
        expansions.append(localeStrings.map(platform.localeExpansion))
        try expansions.append(resolutionStrings.map(platform.resolutionExpansion))
        try expansions.append(deviceStrings.map(platform.deviceExpansion))

        try populateManifestForReleaseInBundle(path, featureExpansions: expansions)
    }
    if shaOpt.wasSet {
        try updateManifestShaInBundle(path)
    }
    if !releaseOpt.wasSet && !shaOpt.wasSet {
        throw CommandLine.ParseError.MissingRequiredOptions([shaOpt, releaseOpt])
    }
} catch {
    cli.printUsage(error)
    let examples = [
        "# Generate image paths for apple with @2x and @3x resolution with iPhone, iPad, and language variation",
        "Breeze -i -p apple --languages=en fr --resolution=2x 3x --device=iphone ipad -b $BUNDLE_PATH",
        "",
        "# Generate image paths for apple with @2x and @3x resolution with language variation",
        "Breeze -i -p apple --languages=en fr --resolution=2x 3x -b $BUNDLE_PATH",
        "",
        "# Generate image paths for apple with @2x and @3x resolution with iPhone and iPad variation, but no language variance",
        "Breeze -i -p apple --resolution=2x 3x --device=iphone ipad -b $BUNDLE_PATH",
        "",
    ]
    print("Examples\n\n  \(examples.joinWithSeparator("\n  "))")
    exit(EX_USAGE)
}


