//
//  SwiftLogging.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 4/21/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation
import Darwin

public class Logger {

    public typealias EventHandler = EventBroadcaster <Event>.Handler

    public internal(set) var destinations:[String:Destination] = [:]
    public internal(set) var filters:[(String, Filter)] = []
    public internal(set) var eventBroadcaster = EventBroadcaster <Event>()

    public let queue = dispatch_queue_create("io.schwa.SwiftLogger", DISPATCH_QUEUE_SERIAL)
    public let consoleQueue = dispatch_queue_create("io.schwa.SwiftLogger.console", DISPATCH_QUEUE_SERIAL)

    internal let startTimestamp:Timestamp = Timestamp()
    internal var count:Int64 = 0
    internal var running:Bool = false

    public init() {
    }

    public func addDestination(key:String, destination:Destination) {
        self.destinations[key] = destination
        destination.logger = self
    }

    public func removeDestination(key:String) {
        let destination = self.destinations[key]
        destination?.logger = nil
        self.destinations.removeValueForKey(key)
    }

    public func addEventHandler(key:String, event:Event, handler:EventHandler) {
        self.eventBroadcaster.addHandler(key, event: event, handler: handler)
    }

    public func removeEventHandler(key:String) {
        self.eventBroadcaster.removeHandler(key)
    }

    public func addFilter(key:String, filter:Filter) {
        self.filters.append((key, filter))
    }

    public func removeFilter(key:String) {
        for (index, (k, _)) in enumerate(self.filters) {
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
        fireTriggers(.startup)
    }

    public func shutdown() {
        if running == false {
            return
        }
        for (_, destination) in destinations {
            destination.shutdown()
        }
        fireTriggers(.shutdown)
    }

    public func log(message:Message, immediate:Bool = false) {

        if immediate == false {
            dispatch_async(queue) {
                self.log(message, immediate:true)
            }
            return
        }

        if count++ == 0 {
            startup()
        }

        var filteredMessage1: Message? = message
        for (key, filter) in filters {
            filteredMessage1 = filter(filteredMessage1!)
            if filteredMessage1 == nil {
                return
            }
        }

        destinationLoop: for (_, destination) in destinations {
            var filteredMessage2: Message? = filteredMessage1
            for filter in destination.filters {
                filteredMessage2 = filter(filteredMessage2!)
                if filteredMessage2 == nil {
                    continue destinationLoop
                }
            }
            destination.receiveMessage(filteredMessage2!)
        }

        fireTriggers(.messageLogged, object: message)
    }

    internal func fireTriggers(event:Event, object:Any? = nil) {
        eventBroadcaster.fireHandlers(event, object: object)
    }

    func internalLog(object:Any?) {
        println(object)
    }
}

extension Logger {

    public func log(object:Any?, priority:Priority = .debug, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(message)
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
    // public let bundleID:String
    // public let version:????
    public let filename:String
    public let function:String
    public let line:Int

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

// MARK: -

public typealias UserInfo = Dictionary <String, Any>

// MARK: -

public struct Message {

    public let string:String
    public let priority:Priority
    public let timestamp:Timestamp?
    public let source:Source
    public let tags:Tags?
    public let userInfo:UserInfo?

    public init(string:String, priority:Priority, timestamp:Timestamp? = Timestamp(), source:Source, tags:Tags? = nil, userInfo:UserInfo? = nil) {
        self.string = string
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }
}

extension Message: Hashable {
    public var hashValue: Int {
        return string.hashValue ^ priority.hashValue ^ source.hashValue ^ (timestamp != nil ? timestamp!.hashValue : 0)
    }
}

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.string == rhs.string && lhs.priority == rhs.priority && lhs.timestamp == rhs.timestamp && lhs.source == rhs.source
}

extension Message {
    public init(message:Message, timestamp:Timestamp?) {
        self.string = message.string
        self.priority = message.priority
        self.timestamp = timestamp
        self.source = message.source
        self.tags = message.tags
        self.userInfo = message.userInfo
    }

    public init(object:Any?, priority:Priority, timestamp:Timestamp? = Timestamp(), source:Source, tags:Tags? = nil, userInfo:UserInfo? = nil) {
        if let object:Any = object {
            self.string = toString(object)
        }
        else {
            self.string = "nil"
        }
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }
}

// MARK: -

public typealias MessageFormatter = Message -> String

// MARK: -

public class Destination {

    public var filters:[Filter] = []
    public internal(set) weak var logger:Logger!

    public init() {
    }

    public func startup() {
    }

    public func receiveMessage(message:Message) {
    }

    public func shutdown() {
    }

}

// MARK: -

public typealias Filter = (Message) -> Message?

// MARK: -

public enum Event {
    case startup
    case messageLogged
    case shutdown
}


