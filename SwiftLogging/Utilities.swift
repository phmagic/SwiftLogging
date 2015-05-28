//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/27/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

internal let iso8601Formatter:NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier:"en_US_POSIX")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSXX"
//    dateFormatter.timeZone = NSTimeZone(name:"UTC")
    return dateFormatter
}()

internal let timeFormatter:NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH':'mm':'ss.SSS"
//    dateFormatter.timeZone = NSTimeZone(name:"UTC")
    return dateFormatter
}()

extension String {
    func escape(# asASCII: Bool, extraCharacters: NSCharacterSet? = nil) -> String {
        let f:[String] = map(self.unicodeScalars) {
            (unicodeScalar:UnicodeScalar) -> String in

            if let extraCharacters = extraCharacters where extraCharacters.longCharacterIsMember(unicodeScalar.value) {

                switch unicodeScalar.value {
                    case 0x07: return "\\a"
                    case 0x08: return "\\b"
                    case 0x0C: return "\\f"
                    case 0x0A: return "\\n"
                    case 0x0D: return "\\r"
                    case 0x09: return "\\t"
                    case 0x0B: return "\\v"
                    case 0x5C: return "\\\\"
                    case 0x27: return "\\'"
                    case 0x22: return "\\\""
                    case 0x3F: return "\\?"
                    default:
                        return NSString(format: "\\u{%X}", unicodeScalar.value) as String
                }
            }

            return unicodeScalar.escape(asASCII: asASCII)
        }
        return "".join(f)
    }
}

public struct Timestamp {
    let timeIntervalSinceReferenceDate:NSTimeInterval

    init() {
        timeIntervalSinceReferenceDate = NSDate().timeIntervalSinceReferenceDate
    }
}

extension Timestamp: Hashable {
    public var hashValue: Int {
        return timeIntervalSinceReferenceDate.hashValue
    }
}

public func ==(lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.timeIntervalSinceReferenceDate == rhs.timeIntervalSinceReferenceDate
}

extension Timestamp: Printable {
    public var description: String {
        return toString
    }
}

extension Timestamp {
    public var toString: String {
        return iso8601Formatter.stringFromDate(asDate)
    }

    public var toTimeString: String {
        return timeFormatter.stringFromDate(asDate)
    }
}

extension Timestamp {
    public var asDate: NSDate {
        return NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
    }
}

// MARK: -

func banner(string:String, width:Int = 72, borderCharacter:Character = "*") -> String {

    let borderString = "\(borderCharacter)"

    var output = "".stringByPaddingToLength(width, withString: borderString, startingAtIndex: 0) + "\n"


    for line in string.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
        var formattedLine = borderString + " " + line
        formattedLine = formattedLine.stringByPaddingToLength(width - 2, withString:" ", startingAtIndex:0)
        formattedLine += " " + borderString + "\n"
        output += formattedLine
    }

    output += "".stringByPaddingToLength(width, withString: borderString, startingAtIndex: 0)

    return output

}
