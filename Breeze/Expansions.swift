//
//  Rule.swift
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum ExpansionError: ErrorType {
    case UnsupportedValue(value: String)
    case AndroidUnsupported
}

protocol PathExpansion {
    func expandPath(path: String) -> String
}

typealias ExpansionSet = [PathExpansion]

func performExpansions(expansionList: [ExpansionSet], onPath: String) -> [String] {
    guard expansionList.count > 0 else {
        return [onPath]
    }

    var results = Array<String>()
    var expansionList = expansionList
    let expansion = expansionList[0]
    expansionList.removeFirst()

    if expansion.count > 0 {
        for pathExpansion in expansion {
            let value = pathExpansion.expandPath(onPath)
            results.appendContentsOf(performExpansions(expansionList, onPath: value))
        }
    }
    else {
        results.appendContentsOf(performExpansions(expansionList, onPath: onPath))
    }
    return results
}

enum AssetType: String, PathExpansion {
    case Strings = "strings"
    case PNG = "png"

    func expandPath(path: String) -> String {
        return path.stringByAppendingString(".\(self.rawValue)")
    }
}

enum Platform: String {
    case Apple = "apple"
    case Android = "android"

    func localeExpansion(localeCode: String) -> PathExpansion {
        switch self {
        case .Apple:
            return LocaleExpansion.Apple(localeCode: localeCode)
        case .Android:
            return LocaleExpansion.Android(localeCode: localeCode)
        }
    }

    func resolutionExpansion(resolution: String) throws -> PathExpansion {
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
    func deviceExpansion(device: String) throws -> PathExpansion {
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
}

enum AppleResolution: String, PathExpansion {
    case Default = ""
    case iOS1x = "1x"
    case iOS2x = "2x"
    case iOS3x = "3x"

    func expandPath(path: String) -> String {
        switch self {
        case .Default:
            return path
        default:
            return path.stringByInsertingAfterPathExtension("@".stringByAppendingString(self.rawValue))
        }
    }
}

enum AppleDevice: String, PathExpansion {
    case iPhone = "iphone"
    case iPad = "ipad"

    func expandPath(path: String) -> String {
        switch self {
        case .iPad:
            return path.stringByInsertingAfterPathExtension("~".stringByAppendingString(self.rawValue))
        case .iPhone:
            return path
        }
    }
}

enum LocaleExpansion: PathExpansion {
    case Apple(localeCode: String)
    case Android(localeCode: String)
    func expandPath(path: String) -> String {
        switch self {
        case .Apple(let localeCode):
            return "\(localeCode).lproj/".stringByAppendingString(path)
        case .Android(let localeCode):
            return "drawable-\(localeCode)/".stringByAppendingString(path)
        }
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

