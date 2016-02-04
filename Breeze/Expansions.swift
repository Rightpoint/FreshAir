//
//  Rule.swift
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation
import FreshAirUtility

enum ExpansionError: ErrorType {
    case UnsupportedValue(value: String)
    case AndroidUnsupported
}

protocol StringExpansion {
    func expandString(path: String) -> String
}

typealias ExpansionSet = [StringExpansion]

extension String {
    func performExpansions(expansionList: [ExpansionSet]) -> [String] {
        guard expansionList.count > 0 else {
            return [self]
        }

        var results = Array<String>()
        var expansionList = expansionList
        let expansion = expansionList[0]
        expansionList.removeFirst()

        if expansion.count > 0 {
            for pathExpansion in expansion {
                let value = pathExpansion.expandString(self)
                results.appendContentsOf(value.performExpansions(expansionList))
            }
        }
        else {
            results.appendContentsOf(self.performExpansions(expansionList))
        }
        return results
    }
}

enum AssetType: String, StringExpansion {
    case Strings = "strings"
    case PNG = "png"

    func expandString(string: String) -> String {
        return string.stringByAppendingString(".\(self.rawValue)")
    }
}

enum Platform: String {
    case Apple = "apple"
    case Android = "android"

    func localeFileType() throws -> StringExpansion {
        switch self {
        case .Apple:
            return AssetType.Strings
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }

    func localeExpansion(localeCode: String) -> StringExpansion {
        switch self {
        case .Apple:
            return LocaleExpansion.Apple(localeCode: localeCode)
        case .Android:
            return LocaleExpansion.Android(localeCode: localeCode)
        }
    }

    func resolutionExpansion(resolution: String) throws -> StringExpansion {
        switch self {
        case .Apple:
            guard let r = AppleResolution(rawValue: resolution) else {
                throw ExpansionError.UnsupportedValue(value: resolution)
            }
            return r
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }

    func deviceExpansion(device: String) throws -> StringExpansion {
        switch self {
        case .Apple:
            guard let r = AppleDevice(rawValue: device) else {
                throw ExpansionError.UnsupportedValue(value: device)
            }
            return r
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }

    func featureExpansion(feature: RZFFeature) throws -> StringExpansion {
        switch self {
        case .Apple:
            return LocalizedFeatureContent.Strings(feature: feature)
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }
}

enum LocalizedFeatureContent : StringExpansion {
    case Strings(feature: RZFFeature)

    func expandString(path: String) -> String {
        switch self {
        case Strings(let feature):
            return ["cat >> \(path) << EOF",
                "\"\(feature.localizedTitleKey())\" = \"Title of Feature \(feature.key)\"",
                "\"\(feature.localizedDescriptionKey())\" = \"Description of Feature \(feature.key)\"",
                "", ].joinWithSeparator("\n")

        }
    }

}


enum AppleResolution: String, StringExpansion {
    case Default = ""
    case iOS1x = "1x"
    case iOS2x = "2x"
    case iOS3x = "3x"

    func expandString(string: String) -> String {
        switch self {
        case .Default:
            return string
        default:
            return string.stringByInsertingAfterPathExtension("@".stringByAppendingString(self.rawValue))
        }
    }
}

enum AppleDevice: String, StringExpansion {
    case iPhone = "iphone"
    case iPad = "ipad"

    func expandString(string: String) -> String {
        switch self {
        case .iPad:
            return string.stringByInsertingAfterPathExtension("~".stringByAppendingString(self.rawValue))
        case .iPhone:
            return string
        }
    }
}

enum LocaleExpansion: StringExpansion {
    case Apple(localeCode: String)
    case Android(localeCode: String)
    func expandString(string: String) -> String {
        switch self {
        case .Apple(let localeCode):
            return "\(localeCode).lproj/".stringByAppendingString(string)
        case .Android(let localeCode):
            return "drawable-\(localeCode)/".stringByAppendingString(string)
        }
    }
}

enum ShellCommand: StringExpansion {
    case Touch

    func expandString(string: String) -> String {
        return "touch \(string)"
    }
}

//enum AndroidResolutions: String {
//    case AndroidLDPI = "ldpi"
//    case AndroidMDPI = "mdpi"
//    case AndroidHDPI = "hdpi"
//    case AndroidXHDPI = "xhdpi"
//    case AndroidXXHDPI = "xxhdpi"
//    case AndroidXXXHDPI = "xxxhdpi"
//}
