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

public func tagFilterIn(_ tags: Tags, replacement: ((Event) -> Event?)? = nil) -> Filter {
    return {
        (event: Event) -> Event? in
        guard let eventTags = event.tags else {
            return nil
        }
        return tags.intersection(eventTags).count == 0 ? replacement?(event) : event
    }
}

public func tagFilterOut(_ tags: Tags, replacement: ((Event) -> Event?)? = nil) -> Filter {
    return {
        (event: Event) -> Event? in
        if let eventTags = event.tags {
            return tags.intersection(eventTags).count > 0 ? replacement?(event) : event
        }
        else {
            return event
        }
    }
}

// MARK: Priority Filter

public func priorityFilter(_ priorities: PrioritySet) -> Filter {
    return {
       (event: Event) -> Event? in
        return priorities.contains(event.priority) ? event : nil
    }
}

public func priorityFilter(_ priorities: [Priority]) -> Filter {
    return priorityFilter(PrioritySet(priorities))
}

// MARK: Duplicates Filter

// TODO: This should filter OUTPUT not input

//public func duplicatesFilter(timeout timeout: NSTimeInterval) -> Filter {
//    var seenEventHashes = [Event: Timestamp] ()
//
//    return {
//       (event: Event) -> Event? in
//        let now = Timestamp()
//        let key = Event(event: event, timestamp: nil)
//        var result: Event? = nil
//        if let lastTimestamp = seenEventHashes[key] {
//            let delta = now.timeIntervalSinceReferenceDate - lastTimestamp.timeIntervalSinceReferenceDate
//            result = delta > timeout ? event : nil
//        }
//        else {
//            result = event
//        }
//        seenEventHashes[key] = event.timestamp
//        return result
//    }
//}

// MARK: Sensitivity Filter

public let sensitivityFilter = tagFilterOut(Tags([sensitiveTag])) {
    return Event(subject: "Sensitive log info redacted.", priority: .warning, timestamp: $0.timestamp, source: $0.source)
}

// MARK: Verbosity Filter

public enum Verbosity: Int {
    case normal = 0
    case verbose = 1
    case veryVerbose = 2

    public init(tags: Tags) {
        if tags.contains(veryVerboseTag) {
            self = .veryVerbose
        }
        if tags.contains(verboseTag) {
            self = .verbose
        }
        else {
            self = .normal
        }
    }
}

extension Verbosity: Comparable {
}

public func <(lhs: Verbosity, rhs: Verbosity) -> Bool {
    return lhs.rawValue < rhs.rawValue
}


// TODO: get rid of very verbose
public func verbosityFilter(verbosityLimit userVerbosityLimit: Verbosity? = nil) -> Filter {
    let verbosityLimit: Verbosity
    if userVerbosityLimit != nil {
        verbosityLimit = userVerbosityLimit!
    }
    else {
        let verbosityRaw = UserDefaults.standard.integer(forKey: "loggingFilterVerbosityLimit")
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

public func sourceFilter(pattern: String? = nil, inclusive: Bool = true) -> Filter {

    var pattern = pattern
    if pattern == nil {
        pattern = UserDefaults.standard.string(forKey: "loggingFilterSourcePattern")
    }

    guard let strongPattern = pattern else {
        return passthroughFilter
    }

    guard let expression = try? NSRegularExpression(pattern: strongPattern, options: NSRegularExpression.Options()) else {
        SwiftLogging.log.internalLog("Pattern provided to SwiftLogging log is not a valid regular expression.")
        return passthroughFilter
    }

    return {
        (event: Event) -> Event? in

        let string = String(describing: event.source)

        let matches = expression.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: (string as NSString).length))
        if inclusive == true {
            if matches == 0 {
                return nil
            }
        }
        else {
            if matches != 0 {
                return nil
            }
        }

        return event
    }
}
