//
//  SwiftLogging+Filters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public let nilFilter = {
   (event: Event) -> Event? in
   return nil
}

// MARK: -

public let passthroughFilter = {
   (event: Event) -> Event? in
   return event
}

// MARK: -

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

// MARK: -

public func priorityFilter(priorities: PrioritySet) -> Filter {
    return {
       (event: Event) -> Event? in
        return priorities.contains(event.priority) ? event : nil
    }
}

public func priorityFilter(priorities: [Priority]) -> Filter {
    return priorityFilter(PrioritySet(priorities))
}

// MARK: -

public func duplicateFilter() -> Filter {
    var seenEventHashes = [Event: Timestamp] ()

    return {
       (event: Event) -> Event? in
        let now = Timestamp()
        let key = Event(event: event, timestamp: nil)
        var result: Event? = nil
        if let lastTimestamp = seenEventHashes[key] {
            let delta = now.timeIntervalSinceReferenceDate - lastTimestamp.timeIntervalSinceReferenceDate
            result = delta > 1.0 ? event : nil
        }
        else {
            result = event
        }
        seenEventHashes[key] = event.timestamp
        return result
    }
}

// MARK: -

public let sensitiveFilter = tagFilterOut(Tags([sensitiveTag])) {
    return Event(subject: "Sensitive log info redacted.", priority: .Warning, timestamp: $0.timestamp, source: $0.source)
}

// MARK: -

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

public func verbosityFilter(tooMuchVerbosity: Verbosity = .Verbose) -> Filter {
    return {
        (event: Event) -> Event? in

        if let tags = event.tags {
            let verbosity = Verbosity(tags: tags)
            if verbosity >= tooMuchVerbosity {
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
