//
//  String+Helpers.swift
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

extension String {
    func stringByInsertingAfterPathExtension(value: String) -> String {
        let nsSelf = self as NSString
        let ext = nsSelf.pathExtension
        var body = nsSelf.stringByDeletingPathExtension
        body.appendContentsOf(value)
        body.appendContentsOf(".")
        body.appendContentsOf(ext)
        return body
    }
}

