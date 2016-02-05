//
//  main.swift
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation
import FreshAirUtility
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

func createManifestForBundle(path: String, conditionBuilders: [DetectCondition]) throws {
    guard let bundleURL = NSURL(string: "file://\(path)"),
        let bundle = NSBundle(URL: bundleURL) else {
            throw BreezeError.InvalidFilePath(path: path)
    }

    let fm = NSFileManager.defaultManager()
    for file in try fm.subpathsOfDirectoryAtPath(path as String) {
        let filePath = (path as NSString).stringByAppendingPathComponent(file)
        var isDir: ObjCBool = false
        let exists = fm.fileExistsAtPath(filePath, isDirectory: &isDir)
        guard exists && !isDir else {
            continue
        }
        var conditions: [RZFCondition] = Array()
        for conditionBuilder in conditionBuilders {
            guard let condition = conditionBuilder(file) else {
                continue
            }
            conditions.append(condition)
        }
        let entry = RZFManifestEntry()
        entry.filename = file
        entry.sha = entry.shaInBundle(bundle)
        entry.conditions = conditions
    }
}

func releaseNotesAtPath(path: String) throws -> RZFReleaseNotes {
    guard let bundleURL = NSURL(string: "file://\(path)") else {
        throw BreezeError.InvalidFilePath(path: path)
    }
    let releaseURL  = bundleURL.URLByAppendingPathComponent(NSURL.rzf_releaseFilename())

    guard let releaseNotes = try RZFReleaseNotes.rzf_importURL(releaseURL) as? RZFReleaseNotes else {
        throw BreezeError.InvalidJSONFormat(path: releaseURL.path!)
    }
    return releaseNotes
}

let cli = CommandLine()
let bundleOpt = StringOption(shortFlag: "b", longFlag: "bundle", helpMessage: "Path to the freshair bundle.")

let shaFlag = BoolOption(shortFlag: "s", longFlag: "sha",  helpMessage: "Calculate all of the sha values in the manifest.")
let manifestFlag = BoolOption(shortFlag: "m", longFlag: "manifest",  helpMessage: "Generate a manifest file based on the contents of the directory.")
let localizeFlag = BoolOption(shortFlag: "l", longFlag: "localize",  helpMessage: "Generate localization files for the features in the release")
let imageFlag = BoolOption(shortFlag: "i", longFlag: "images",  helpMessage: "Generate images for the flags 'languages', 'resolution', and 'device'")

let platformOpt = EnumOption<Platform>(shortFlag: "p", longFlag: "platform",  helpMessage: "The platform to generate for. apple or android.")
let languageOpt = MultiStringOption(longFlag: "languages",  helpMessage: "Generate files for all of the languages")
let resolutionOpt = MultiStringOption(longFlag: "resolution",  helpMessage: "Generate files for all of the resolutions")
let deviceOpt = MultiStringOption(longFlag: "device",  helpMessage: "Generate files for all of the devices")

cli.addOptions(bundleOpt, shaFlag, manifestFlag, imageFlag, localizeFlag, platformOpt, languageOpt, resolutionOpt, deviceOpt)

do {
    try cli.parse()
    let path = bundleOpt.value ?? "./"
    if imageFlag.wasSet {
        let platform = platformOpt.value ?? .Apple
        let localeStrings = languageOpt.value ?? []
        let resolutionStrings = resolutionOpt.value ?? []
        let deviceStrings = deviceOpt.value ?? []

        let expansions: [ExpansionSet] = [
            [AssetType.PNG],
            localeStrings.map(platform.localeExpansion),
            try resolutionStrings.map(platform.resolutionExpansion),
            try deviceStrings.map(platform.deviceExpansion),
            [ShellCommand.Touch]
        ]

        let releaseNotes = try releaseNotesAtPath(path)
        print("# Copy and Paste the following commands")
        let output = releaseNotes.features.map() {
            $0.key.performExpansions(expansions)
            }.flatten()

        print(output.joinWithSeparator("\n"))
    }
    else if localizeFlag.wasSet {
        let platform = platformOpt.value ?? .Apple
        let localeStrings = languageOpt.value ?? []

        let releaseNotes = try releaseNotesAtPath(path)
        let expansions: [ExpansionSet] = [
            try [platform.localeFileType()],
            localeStrings.map(platform.localeExpansion),
            try releaseNotes.features.map(platform.featureExpansion)
        ]
        print("# Copy and Paste the following commands")
        print("release_notes".performExpansions(expansions).joinWithSeparator("\n"))
    }
    else if shaFlag.wasSet {
        try updateManifestShaInBundle(path)
    }
    else if manifestFlag.wasSet {
        let platform = platformOpt.value ?? .Apple

        try createManifestForBundle(path, conditionBuilders:[
            platform.localeCondition,
            try platform.deviceCondition(),
            try platform.resolutionCondition(),
            ])
    }
    else {
        throw CommandLine.ParseError.MissingRequiredOptions([shaFlag, manifestFlag, localizeFlag, imageFlag])
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
        "# Generate localizable.strings files populated with the release note keys.",
        "Breeze -l --languages=en fr -b $BUNDLE_PATH",
        "",
    ]
    print("Examples\n\n  \(examples.joinWithSeparator("\n  "))")
    exit(EX_USAGE)
}


