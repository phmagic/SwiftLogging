//
//  SwiftLogging+Filters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

// MARK: nilFilter

public let nilFilter = {
   (event: Event) -> Event? in
   return nil
}

// MARK: Passthrough (NOP) filter

public let passthroughFilter = {
   (event: Event) -> Event? in
   return event
}

// MARK: Tag Filters

public func tagFilterIn(tags: Tags, replacement: (Event -> Event?)? = nil) -> Filter {
    return {
        (event: Event) -> Event? in
        if let eventTags = event.tags {
            return tags.intersect(eventTags).count == 0 ? replacement?(event) : event
        }
        else {
            return event
        }
    }
}

public func tagFilterOut(tags: Tags, replacement: (Event -> Event?)? = nil) -> Filter {
    return {
        (event: Event) -> Event? in
        if let eventTags = event.tags {
            return tags.intersect(eventTags).count > 0 ? replacement?(event) : event
        }
        else {
            return event
        }
    }
}

// MARK: Priority Filter

public func priorityFilter(priorities: PrioritySet) -> Filter {
    return {
       (event: Event) -> Event? in
        return priorities.contains(event.priority) ? event : nil
    }
}

public func priorityFilter(priorities: [Priority]) -> Filter {
    return priorityFilter(PrioritySet(priorities))
}

// MARK: Duplicates Filter

public func duplicatesFilter(timeout: NSTimeInterval) -> Filter {
    var seenEventHashes = [Event: Timestamp] ()

    return {
       (event: Event) -> Event? in
        let now = Timestamp()
        let key = Event(event: event, timestamp: nil)
        var result: Event? = nil
        if let lastTimestamp = seenEventHashes[key] {
            let delta = now.timeIntervalSinceReferenceDate - lastTimestamp.timeIntervalSinceReferenceDate
            result = delta > timeout ? event : nil
        }
        else {
            result = event
        }
        seenEventHashes[key] = event.timestamp
        return result
    }
}

// MARK: Sensitivity Filter

public let sensitivityFilter = tagFilterOut(Tags([sensitiveTag])) {
    return Event(subject: "Sensitive log info redacted.", priority: .Warning, timestamp: $0.timestamp, source: $0.source)
}

// MARK: Verbosity Filter

public enum Verbosity: Int {
    case Normal = 0
    case Verbose = 1
    case VeryVerbose = 2

    public init(tags: Tags) {
        if tags.contains(veryVerboseTag) {
            self = .VeryVerbose
        }
        if tags.contains(verboseTag) {
            self = .Verbose
        }
        else {
            self = .Normal
        }
    }
}

extension Verbosity: Comparable {
}

public func <(lhs: Verbosity, rhs: Verbosity) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func verbosityFilter(userVerbosityLimit: Verbosity? = nil) -> Filter {
    let verbosityLimit: Verbosity
    if userVerbosityLimit != nil {
        verbosityLimit = userVerbosityLimit!
    }
    else {
        let verbosityRaw = NSUserDefaults.standardUserDefaults().integerForKey("logging_filter_verbosity_limit")
        verbosityLimit = Verbosity(rawValue:verbosityRaw)!
    }

    return {

        (event: Event) -> Event? in

        if let tags = event.tags {
            let verbosity = Verbosity(tags: tags)
            if verbosity >= verbosityLimit {
                return nil
            }
            else {
                return event
            }
        }
        else {
            return event
        }
    }
}

// MARK: Source Filter

public func sourceFilter(pattern: String? = nil) -> Filter {

    var pattern = pattern
    if pattern == nil {
        pattern = NSUserDefaults.standardUserDefaults().stringForKey("logging_filter_source_pattern")
    }

    guard let strongPattern = pattern else {
        SwiftLogging.log.internalLog("No pattern provided to sourceFilter(). Use logging_filter_source_pattern user default (Put `-logging_filter_source_pattern <regex>` in your run scheme.)")
        return passthroughFilter
    }

    guard let expression = try? NSRegularExpression(pattern: strongPattern, options: NSRegularExpressionOptions()) else {
        SwiftLogging.log.internalLog("Pattern provided to SwiftLogging log is not a valid regular expression.")
        return passthroughFilter
    }

    return {
        (event: Event) -> Event? in

        let string = String(event.source)

        if expression.numberOfMatchesInString(string, options: NSMatchingOptions(), range: NSRange(location: 0, length: (string as NSString).length)) == 0 {
            return nil
        }

        return event
    }
}
