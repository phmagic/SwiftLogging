//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/27/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

internal let iso8601Formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSXX"
//    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    return dateFormatter
}()

internal let timeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH':'mm':'ss.SSS"
//    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    return dateFormatter
}()

extension String {
    func escape(asASCII: Bool, extraCharacters: CharacterSet? = nil) -> String {
        let f: [String] = self.unicodeScalars.map {
            (unicodeScalar: UnicodeScalar) -> String in

            if let extraCharacters = extraCharacters , extraCharacters.contains(UnicodeScalar(unicodeScalar.value)!) {

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

            return unicodeScalar.escaped(asASCII: asASCII)
        }
        return f.joined(separator: "")
    }
}

// MARK: -

public struct Timestamp {
    let timeIntervalSinceReferenceDate: TimeInterval

    init() {
        timeIntervalSinceReferenceDate = Date().timeIntervalSinceReferenceDate
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

extension Timestamp: CustomStringConvertible {
    public var description: String {
        return toString
    }
}

public extension Timestamp {
    var toString: String {
        return iso8601Formatter.string(from: asDate)
    }

    public var toTimeString: String {
        return timeFormatter.string(from: asDate)
    }
}

public extension Timestamp {
    var asDate: Date {
        return Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
    }
}

// MARK: -

public func banner(_ string: String, width: Int = 72, borderCharacter: Character = "*") -> String {

    let borderString = "\(borderCharacter)"

    var output = "".padding(toLength: width, withPad: borderString, startingAt: 0) + "\n"


    for line in string.components(separatedBy: CharacterSet.newlines) {
        var formattedLine = borderString + " " + line
        formattedLine = formattedLine.padding(toLength: width - 2, withPad: " ", startingAt: 0)
        formattedLine += " " + borderString + "\n"
        output += formattedLine
    }

    output += "".padding(toLength: width, withPad: borderString, startingAt: 0)

    return output
}

// TODO: Move to SwiftUtilities & make public

internal extension DispatchData {
    init(data: Data) {
        self = data.withUnsafeBytes() {
            (bytes: UnsafePointer <UInt8>) -> DispatchData in

            let buffer = UnsafeBufferPointer <UInt8> (start: bytes, byteCount: data.count)
            return DispatchData(bytes: buffer)
        }
    }
}
