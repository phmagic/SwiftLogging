//
//  SwiftLogging.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 4/21/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation
import Darwin

public var log = Logger.sharedInstance

public class Logger {

    static let sharedInstance = Logger()

    public internal(set) var destinations: [String: Destination] = [:]
    public internal(set) var filters: [(String, Filter)] = []

    public let queue = dispatch_queue_create("io.schwa.SwiftLogger", DISPATCH_QUEUE_SERIAL)
    public let consoleQueue = dispatch_queue_create("io.schwa.SwiftLogger.console", DISPATCH_QUEUE_SERIAL)

    internal let startTimestamp: Timestamp = Timestamp()
    internal var count: Int64 = 0
    internal var running: Bool = false

    public init() {
    }

    public func addDestination(key: String, destination: Destination) {
        self.destinations[key] = destination
        destination.logger = self
    }

    public func removeDestination(key: String) {
        let destination = self.destinations[key]
        destination?.logger = nil
        self.destinations.removeValueForKey(key)
    }

    public func addFilter(key: String, filter: Filter) {
        self.filters.append((key, filter))
    }

    public func removeFilter(key: String) {
        for (index, (k, _)) in self.filters.enumerate() {
            if key == k {
                self.filters.removeAtIndex(index)
                break
            }
        }
    }

    public func startup() {
        running = true
        for (_, destination) in destinations {
            destination.startup()
        }
    }

    public func shutdown() {
        if running == false {
            return
        }
        for (_, destination) in destinations {
            destination.shutdown()
        }
    }

    public func flush() {
        for (_, destination) in destinations {
            destination.flush()
        }
    }

    public func log(event: Event, immediate: Bool = false) {

        if immediate == false {
            dispatch_async(queue) {
                self.log(event, immediate: true)
            }
            return
        }

        if count++ == 0 {
            startup()
        }

        let shouldFlush = event.tags?.contains(flushTag)

        var filteredEvent1: Event? = event
        for (_, filter) in filters {
            filteredEvent1 = filter(filteredEvent1!)
            if filteredEvent1 == nil {
                return
            }
        }

        destinationLoop: for (_, destination) in destinations {
            var filteredEvent2: Event? = filteredEvent1
            for filter in destination.filters {
                filteredEvent2 = filter(filteredEvent2!)
                if filteredEvent2 == nil {
                    continue destinationLoop
                }
            }
            destination.receiveEvent(filteredEvent2!)
        }

        if shouldFlush == true {
            flush()
        }
    }

    func internalLog(subject: Any?) {
        dispatch_async(consoleQueue) {
            print(subject)
        }
    }
}

// MARK: -

public enum Priority: Int8 {
    case Debug
    case Info
    case Warning
    case Error
    case Critical
}

// MARK: -

public typealias PrioritySet = Set <Priority>

// MARK: -

public struct Source {
    // public let bundleID: String
    // public let version: ????
    public let filename: String
    public let function: String
    public let line: Int

    public init(filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        self.filename = filename
        self.function = function
        self.line = line
    }
}

extension Source: Hashable {
    public var hashValue: Int {
        return filename.hashValue ^ function.hashValue ^ line.hashValue
    }
}

public func ==(lhs: Source, rhs: Source) -> Bool {
    return lhs.filename == rhs.filename && lhs.function == rhs.function && lhs.line == rhs.line
}

// MARK: -

public typealias Tags = Set <String>

// MARK: -

public let preformattedTag = "preformatted"
public let sensitiveTag = "sensitive"
public let verboseTag = "verbose"
public let veryVerboseTag = "verbose+"
public let flushTag = "flush"

// MARK: -

public typealias UserInfo = Dictionary <String, Any>

// MARK: -

public struct Event {


    // TODO: we'd like formatters to be able to special case subject formatting. We rely on String(subject) currently

    public let subject: String // Should this be an any?
    public let priority: Priority
    public let timestamp: Timestamp?
    public let source: Source
    public let tags: Tags?
    public let userInfo: UserInfo?

    public init(subject: String, priority: Priority, timestamp: Timestamp? = Timestamp(), source: Source, tags: Tags? = nil, userInfo: UserInfo? = nil) {
        self.subject = subject
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }
}

extension Event: Hashable {
    public var hashValue: Int {
        return subject.hashValue ^ priority.hashValue ^ source.hashValue ^ (timestamp != nil ? timestamp!.hashValue : 0)
    }
}

public func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.subject == rhs.subject && lhs.priority == rhs.priority && lhs.timestamp == rhs.timestamp && lhs.source == rhs.source
}

extension Event {
    public init(event: Event, timestamp: Timestamp?) {
        self.subject = event.subject
        self.priority = event.priority
        self.timestamp = timestamp
        self.source = event.source
        self.tags = event.tags
        self.userInfo = event.userInfo
    }

    public init(subject: Any?, priority: Priority, timestamp: Timestamp? = Timestamp(), source: Source, tags: Tags? = nil, userInfo: UserInfo? = nil) {
        if let subject: Any = subject {
            self.subject = String(subject)
        }
        else {
            // TODO: Really?
            self.subject = "nil"
        }
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }
}

// MARK: -

public typealias EventFormatter = Event -> String

// MARK: -

public class Destination {

    public var filters: [Filter] = []
    public internal(set) weak var logger: Logger!

    public init() {
    }

    public func startup() {
    }

    public func receiveEvent(event: Event) {
    }

    public func shutdown() {
    }

    public func flush() {
    }

    public func addFilter(filter: Filter) {
        filters.append(filter)
    }
}

// MARK: -

public typealias Filter = (Event) -> Event?
