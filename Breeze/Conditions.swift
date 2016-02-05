//
//  Conditions.swift
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation
import FreshAirUtility

typealias DetectCondition = (String) -> RZFCondition?

extension Platform {
    func localeCondition(path: String) -> RZFCondition? {
        let nsPath = path as NSString
        if let dir = nsPath.componentsSeparatedByString("/").first {
            switch self {
            case .Apple:
                let splitDir = dir.componentsSeparatedByString(".")
                if splitDir.count == 2 && splitDir[1] == "lproj" {
                    return RZFCondition(key: "locale", comparison: "eq", value: splitDir[0])
                }
            case .Android:
                let splitDir = dir.componentsSeparatedByString("-")
                if splitDir.count > 2 &&
                    splitDir[0] == "drawable" &&
                    NSLocale.availableLocaleIdentifiers().contains(splitDir[1]) {
                        return RZFCondition(key: "locale", comparison: "eq", value: splitDir[1])
                }
            }
        }
        return nil
    }

    func resolutionCondition() throws -> DetectCondition {
        switch self {
        case .Apple:
            return AppleResolution.resolutionCondition
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }

    func deviceCondition() throws -> DetectCondition {
        switch self {
        case .Apple:
            return AppleDevice.deviceCondition
        case .Android:
            throw ExpansionError.AndroidUnsupported
        }
    }
}

extension AppleResolution {
    static func resolutionCondition(path: String) -> RZFCondition? {
        for key in ["1", "2", "3"] {
            if path.containsString("@\(key)x") {
                // RZFEnvironmentDisplayScaleKey isn't linking ><
                return RZFCondition(key: "displayScale", comparison: "eq", value: key)
            }
        }
        return nil;
    }
}

extension AppleDevice {
    static func deviceCondition(path: String) -> RZFCondition? {
        for key in ["ipad", "iphone"] {
            if path.containsString("~\(key).") {
                // RZFEnvironmentDeviceKey isn't linking ><
                return RZFCondition(key: "device", comparison: "eq", value: key)
            }
        }
        return nil;
    }
}