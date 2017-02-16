//
//  SwiftLogging.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 4/21/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation
import Darwin
import SwiftUtilities

public var log = Logger.sharedInstance

open class Logger {

    static let sharedInstance = Logger()

    open internal(set) var destinations: [String: Destination] = [:]
    open internal(set) var filters: [(String, Filter)] = []

    open let queue = DispatchQueue(label: "io.schwa.SwiftLogger", attributes: [])
    open let consoleQueue = DispatchQueue(label: "io.schwa.SwiftLogger.console", attributes: [])

    internal let startTimestamp: Timestamp = Timestamp()
    internal var count: Int64 = 0
    internal var running: Bool = false

    internal var lock = NSRecursiveLock()

    public init() {
    }

    open func addDestination(_ destination: Destination) {
        lock.with() {
            let key = destination.identifier
            self.destinations[key] = destination
            destination.logger = self
            do {
                if running == true {
                    try destination.startup()
                }
            }
            catch let error {
                internalLog("Failed to start destination: \(destination.identifier) - \(error)")
            }
        }
    }

    open func removeDestination(_ key: String) {
        lock.with() {
            guard let destination = self.destinations[key] else {
                return
            }
            self.destinations.removeValue(forKey: key)
            do {
                try destination.shutdown()
            }
            catch let error {
                internalLog("Failed to shut down destination: \(destination.identifier) - \(error)")
            }
            destination.logger = nil
        }
    }

    open func destinationForKey(_ key: String) -> Destination? {
        return lock.with() {
            return destinations[key]
        }
    }

    open func addFilter(key: String, filter: @escaping Filter) {
        lock.with() {
            self.filters.append((key, filter))
        }
    }

    open func removeFilter(_ key: String) {
        lock.with() {
            for (index, (k, _)) in self.filters.enumerated() {
                if key == k {
                    self.filters.remove(at: index)
                    break
                }
            }
        }
    }

    open func startup() {
        lock.with() {
            running = true
            for (_, destination) in destinations {
                do {
                    try destination.startup()
                }
                catch let error {
                    internalLog("Failed to start up logging destination: \(destination.identifier) - \(error)")
                }
            }
        }
    }

    open func shutdown() {
        lock.with() {
            if running == false {
                return
            }

            for (_, destination) in destinations {
                do {
                    try destination.shutdown()
                }
                catch let error {
                    internalLog("Failed to shut down logging destination: \(destination.identifier) - \(error)")
                }
            }
        }
    }

    open func flush() {
        lock.with() {
            for (_, destination) in destinations {
                do {
                    try destination.flush()
                }
                catch let error {
                    internalLog("Failed to flush logging destination: \(destination.identifier) - \(error)")
                }
            }
        }
    }

    open func log(event: Event, immediate: Bool = false) {

        var filters: [(String, Filter)]!
        var destinations: [String: Destination]!

        lock.with() {
            if count == 0 {
                startup()
            }
            count += 1
            
            filters = self.filters
            destinations = self.destinations
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
            for (key, filter) in destination.filters {
                filteredEvent2 = filter(filteredEvent2!)
                if filteredEvent2 == nil {
                    internalLog("Filtered out by \(key)")
                    continue destinationLoop
                }
            }

            let formattedEvent = filteredEvent2!.formatted(with: destination.formatter)

            if immediate == false {
                queue.async {
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


    var isInternalLogEnabled = false
    
    func internalLog(_ items: Any..., separator: String = " ") {
        guard isInternalLogEnabled == true else {
            return
        }
        consoleQueue.async {
            let subject = items.map(String.init(describing:)).joined(separator: separator)
            print("SwiftLogging Internal:", subject)
        }
    }
}

// MARK: -

public enum Priority: Int8 {
    case debug
    case info
    case warning
    case error
    case critical
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
        case raw(items: [Any], separator: String)
        case formatted(String)
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

    public init(id:Int? = nil, items: [Any], separator: String = " ", priority: Priority, timestamp: Timestamp? = Timestamp(), source: Source, tags: Tags? = nil, userInfo: UserInfo? = nil) {
        self = Event(id: id, subject: .raw(items: items, separator: separator), priority: priority, timestamp: timestamp, source: source, tags: tags, userInfo: userInfo)
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

public typealias EventFormatter = (Event) -> String


public extension Event {
    func formatted(with formatter:EventFormatter) -> Event {
        let string = formatter(self)
        let formattedSubject = Subject.formatted(string)
        return Event(id: id, subject: formattedSubject, priority: priority, timestamp: timestamp, source: source, tags: tags, userInfo: userInfo)
    }
}

// MARK: -

open class Destination {

    open internal(set) weak var logger: Logger!

    open let identifier: String
    open var filters: [(String, Filter)] = []
    open var formatter: EventFormatter = terseFormatter

    public init(identifier: String) {
        self.identifier = identifier
    }

    open func startup() throws {
    }

    open func receiveEvent(_ event: Event) {
    }

    open func shutdown() throws {
    }

    open func flush() throws {
    }

    open func addFilter(key: String, filter: @escaping Filter) {
        filters.append((key, filter))
    }
}

// MARK: -

public typealias Filter = (Event) -> Event?
