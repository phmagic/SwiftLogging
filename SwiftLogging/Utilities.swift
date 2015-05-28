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
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSXX"
//    dateFormatter.timeZone = NSTimeZone(name:"UTC")
    return dateFormatter
}()

public struct Timestamp {
    let timeIntervalSinceReferenceDate:NSTimeInterval

    init() {
        timeIntervalSinceReferenceDate = NSDate().timeIntervalSinceReferenceDate
    }
}

extension Timestamp: Hashable {
    public var hashValue: Int {
        get {
            return timeIntervalSinceReferenceDate.hashValue
        }
    }
}

public func ==(lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.timeIntervalSinceReferenceDate == rhs.timeIntervalSinceReferenceDate
}

extension Timestamp: Printable {
    public var description: String {
        get {
            return toString
        }
    }
}

extension Timestamp {
    public var toString: String {
        get {
            let date = NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
            let string = iso8601Formatter.stringFromDate(date)
            return string
        }
    }
}
