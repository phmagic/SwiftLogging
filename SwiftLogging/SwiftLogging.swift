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

    public func addDestination(destination: Destination) {
        let key = destination.identifier
        self.destinations[key] = destination
        destination.logger = self
        
        if running == true {
            destination.startup()
        }
    }

    public func removeDestination(key: String) {
        let destination = self.destinations[key]
        destination?.shutdown()
        destination?.logger = nil
        self.destinations.removeValueForKey(key)

    }

    public func destinationForKey(key: String) -> Destination? {
        return destinations[key]
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

        if count == 0 {
            startup()
        }
        count += 1

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

            let formattedEvent = filteredEvent2!.formatted(with: destination.formatter)

            if immediate == false {
                dispatch_async(queue) {
                    destination.receiveEvent(formattedEvent)
                }
            }
            else {
                destination.receiveEvent(formattedEvent)
            }

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

    public init(filename: String = #file, function: String = #function, line: Int = #line) {
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

    public enum Subject {
        case Raw(Any?)
        case Formatted(String)
    }

    static var nextID: Int = 0

    static func generateID() -> Int {
        let id = nextID
        nextID += 1
        return id
    }

    // TODO: we'd like formatters to be able to special case subject formatting. We rely on String(subject) currently

    public let id: Int
    public let subject: Subject
    public let priority: Priority
    public let timestamp: Timestamp?
    public let source: Source
    public let tags: Tags?
    public let userInfo: UserInfo?

    public init(id:Int? = nil, subject: Subject, priority: Priority, timestamp: Timestamp? = Timestamp(), source: Source, tags: Tags? = nil, userInfo: UserInfo? = nil) {
        self.id = id ?? Event.generateID()
        self.subject = subject
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }

    public init(id:Int? = nil, subject: Any?, priority: Priority, timestamp: Timestamp? = Timestamp(), source: Source, tags: Tags? = nil, userInfo: UserInfo? = nil) {
        self = Event(id: id, subject: .Raw(subject), priority: priority, timestamp: timestamp, source: source, tags: tags, userInfo: userInfo)
    }

}

extension Event: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
}

public func ==(lhs: Event, rhs: Event) -> Bool {
    // TODO: This can be inaccurate when we make copies.
    return lhs.id == rhs.id
}

// MARK: -

public typealias EventFormatter = Event -> String


public extension Event {
    func formatted(with formatter:EventFormatter) -> Event {
        let string = formatter(self)
        let formattedSubject = Subject.Formatted(string)
        return Event(id: id, subject: formattedSubject, priority: priority, timestamp: timestamp, source: source, tags: tags, userInfo: userInfo)
    }
}

// MARK: -

public class Destination {

    public internal(set) weak var logger: Logger!

    public let identifier: String
    public var filters: [Filter] = []
    public var formatter: EventFormatter = terseFormatter

    public init(identifier: String) {
        self.identifier = identifier
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
