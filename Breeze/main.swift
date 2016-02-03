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

func populateImageFilesForReleaseInBundle(path: String, featureExpansions: [ExpansionSet]) throws {
    let releaseNotes = try releaseNotesAtPath(path)
    print("# Copy and Paste the following commands")
    let paths = releaseNotes.features.map() {
        return performExpansions(featureExpansions, onPath: $0.key)
    }.flatten()

    let commands = paths.map() { "touch \($0)" }
    print(commands.joinWithSeparator("\n"))
}

func populateStringsFilesForReleaseInBundle(path: String, featureExpansions: [ExpansionSet]) throws {
    let releaseNotes = try releaseNotesAtPath(path)
    let paths = ["release_notes"].map() {
        return performExpansions(featureExpansions, onPath: $0)
    }.flatten()
    func addLocalizableEntry(feature: RZFFeature) -> String {
        return [
            "\"\(feature.localizedTitleKey())\" = \"Title of Feature \(feature.key)\"",
            "\"\(feature.localizedDescriptionKey())\" = \"Description of Feature \(feature.key)\"",
            "",
        ].joinWithSeparator("\n")
    }
    let commands: [String] = paths.map() {
        var output = ["cat > \($0) << EOF"]
        let content = releaseNotes.features.map(addLocalizableEntry)
        output.appendContentsOf(content)
        output.append("EOF")
        return output.joinWithSeparator("\n")
    }
    print(commands.joinWithSeparator("\n"))

}
let cli = CommandLine()
let bundleOpt = StringOption(shortFlag: "b", longFlag: "bundle", helpMessage: "Path to the freshair bundle.")
let shaFlag = BoolOption(shortFlag: "s", longFlag: "sha",  helpMessage: "Calculate all of the sha values in the manifest.")

let localizeFlag = BoolOption(shortFlag: "l", longFlag: "localize",  helpMessage: "Generate localization files for the features in the release")

let imageFlag = BoolOption(shortFlag: "i", longFlag: "images",  helpMessage: "Generate images for the flags 'languages', 'resolution', and 'device'")
let platformOpt = EnumOption<Platform>(shortFlag: "p", longFlag: "platform",  helpMessage: "The platform to generate for. apple or android.")
let languageOpt = MultiStringOption(longFlag: "languages",  helpMessage: "Generate files for all of the languages")
let resolutionOpt = MultiStringOption(longFlag: "resolution",  helpMessage: "Generate files for all of the resolutions")
let deviceOpt = MultiStringOption(longFlag: "device",  helpMessage: "Generate files for all of the devices")

cli.addOptions(bundleOpt, shaFlag, imageFlag, localizeFlag, platformOpt, languageOpt, resolutionOpt, deviceOpt)

do {
    try cli.parse()
    let path = bundleOpt.value ?? "./"
    if imageFlag.wasSet {
        let platform = platformOpt.value ?? .Apple
        let localeStrings = languageOpt.value ?? []
        let resolutionStrings = resolutionOpt.value ?? []
        let deviceStrings = deviceOpt.value ?? []

        var expansions: [ExpansionSet] = Array()
        expansions.append([AssetType.PNG])
        expansions.append(localeStrings.map(platform.localeExpansion))
        try expansions.append(resolutionStrings.map(platform.resolutionExpansion))
        try expansions.append(deviceStrings.map(platform.deviceExpansion))

        try populateImageFilesForReleaseInBundle(path, featureExpansions: expansions)
    }
    if localizeFlag.wasSet {
        let platform = platformOpt.value ?? .Apple
        let localeStrings = languageOpt.value ?? []

        var expansions: [ExpansionSet] = Array()
        expansions.append([AssetType.Strings])
        expansions.append(localeStrings.map(platform.localeExpansion))
        try populateStringsFilesForReleaseInBundle(path, featureExpansions: expansions)
    }
    if shaFlag.wasSet {
        try updateManifestShaInBundle(path)
    }
    if !imageFlag.wasSet && !shaFlag.wasSet && !localizeFlag.wasSet {
        throw CommandLine.ParseError.MissingRequiredOptions([shaFlag, imageFlag])
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


