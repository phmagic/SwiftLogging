//
//  SwiftLogging+Filters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public let nilFilter = {
   (message:Message) -> Message? in
   return nil
}

// MARK: -

public let passthroughFilter = {
   (message:Message) -> Message? in
   return message
}

// MARK: -

public func tagFilterOut(tags:Tags, replacement:(Message -> Message?)? = nil) -> Filter {
    return {
        (message:Message) -> Message? in
        if let messageTags = message.tags {
            return tags.intersect(messageTags).count > 0 ? replacement?(message) : message
        }
        else {
            return message
        }
    }
}

// MARK: -

public func priorityFilter(priorities:PrioritySet) -> Filter {
    return {
       (message:Message) -> Message? in
        return priorities.contains(message.priority) ? message : nil
    }
}

public func priorityFilter(priorities:[Priority]) -> Filter {
    return priorityFilter(PrioritySet(priorities))
}

// MARK: -

var seenMessageHashes = [Message:Timestamp] ()

public func duplicateFilter() -> Filter {
    return {
       (message:Message) -> Message? in
        let now = Timestamp()
        let key = Message(message: message, timestamp: nil)
        var result:Message? = nil
        if let lastTimestamp = seenMessageHashes[key] {
            let delta = now.timeIntervalSinceReferenceDate - lastTimestamp.timeIntervalSinceReferenceDate
            result = delta > 0.5 ? message : nil
        }
        else {
            result = message
        }
        seenMessageHashes[key] = message.timestamp
        return result
    }
}

// MARK: -

public let sensitiveFilter = tagFilterOut(Tags([sensitiveTag])) {
    return Message(string: "Sensitive log info redacted.", priority: .warning, timestamp: $0.timestamp, source: $0.source)
}
