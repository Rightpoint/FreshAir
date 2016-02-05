//
//  Types.swift
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

enum Platform: String {
    case Apple = "apple"
    case Android = "android"
}

enum LocaleExpansion {
    case Apple(localeCode: String)
    case Android(localeCode: String)
}

enum AssetType: String {
    case Strings = "strings"
    case PNG = "png"
}

enum AppleResolution: String {
    case Default = ""
    case iOS1x = "1x"
    case iOS2x = "2x"
    case iOS3x = "3x"
}

enum AppleDevice: String {
    case iPhone = "iphone"
    case iPad = "ipad"
}

enum AndroidResolutions: String {
    case LDPI = "ldpi"
    case MDPI = "mdpi"
    case HDPI = "hdpi"
    case XHDPI = "xhdpi"
    case XXHDPI = "xxhdpi"
    case XXXHDPI = "xxxhdpi"
}

enum LocalizedFeatureContent {
    case Strings(feature: RZFFeature)
}

enum ShellCommand {
    case Touch
}
