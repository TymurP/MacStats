//
//  Utils.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 15.11.20.
//

import SwiftUI
import Cocoa
import os.log

struct Utils {
        
    static let TIMER = Timer.publish(every: 2, on: .current, in: .common).autoconnect()
    static var system = System.init()
    
    @available(OSX 11.0, *)
    static let logger = Logger()
    
    public static func handleError(msg: String) {
        if #available(OSX 11.0, *) {
            logger.error("Error: \(msg)")
        } else {
            print(msg)
        }
    }
}

extension CGFloat {
    func trim(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    func trim() -> String {
        return String(format: "%.0f", self)
    }
}

extension Double {
    func trim(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    func trim() -> String {
        return String(format: "%.0f", self)
    }
}

extension String {
    
    public mutating func findAndCrop(pattern: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        let stringRange = NSRange(location: 0, length: utf16.count)
        var line = self

        if let searchRange = regex.firstMatch(in: self, options: [], range: stringRange) {
            let start = self.index(self.startIndex, offsetBy: searchRange.range.lowerBound)
            let end = self.index(self.startIndex, offsetBy: searchRange.range.upperBound)
            let value  = String(self[start..<end]).trimmingCharacters(in: .whitespaces)
            line = self.replacingOccurrences(
                of: value,
                with: "",
                options: .regularExpression
            )
            self = line.trimmingCharacters(in: .whitespaces)
            return value.trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
}
