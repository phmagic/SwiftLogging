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

    private(set) var destinations:[Destination] = []
    private(set) var filters:[(String,Filter)] = []
    private(set) var triggers:[String:Trigger] = [:]

    private let startTimestamp:Timestamp = Timestamp()
    private let queue = dispatch_queue_create("io.schwa.SwiftLogger", DISPATCH_QUEUE_SERIAL)
    private var count:Int64 = 0
    private var running:Bool = false

    public init() {
    }

    public final func startup() {
        dispatch_barrier_sync(queue) {
            self._startup()
        }
    }

    private func _startup() {
        running = true
        fireTriggers(Event.startup)
        for destination in destinations {
            destination.startup()
        }
        _log(Message(string:"Logging Started", priority:.info, source:Source()))
    }


    public final func shutdown() {
        dispatch_barrier_sync(queue) {
            self._shutdown()
        }
    }

    private func _shutdown() {
        if running == false {
            return
        }
        for destination in destinations {
            destination.shutdown()
        }
        fireTriggers(Event.shutdown)
    }

    public func addDestination(key:String, destination:Destination) {
        dispatch_barrier_sync(queue) {
            self.destinations.append(destination)
        }
    }

    public func removeDestination(key:String) {
        dispatch_barrier_sync(queue) {
            // TODO
        }
    }

    public func addTrigger(key:String, trigger:Trigger) {
        dispatch_barrier_sync(queue) {
            self.triggers[key] = trigger
        }
    }

    public func removeTrigger(key:String) {
        dispatch_barrier_sync(queue) {
            self.triggers.removeValueForKey(key)
        }
    }

    public func addFilter(key:String, filter:Filter) {
        dispatch_barrier_sync(queue) {
            self.filters.append((key, filter))
        }
    }

    public func removeFilter(key:String, filter:Filter) {
        dispatch_barrier_sync(queue) {
            // TODO
        }
    }

    public final func log(message:Message) {
        dispatch_async(queue) {
            self._log(message)
        }
    }

    private func _log(message:Message) {
        if count++ == 0 {
            _startup()
        }

        let event = Event.messageLogged(message)
        fireTriggers(event)

        var filteredMessage1: Message? = message
        for (key, filter) in filters {
            filteredMessage1 = filter(filteredMessage1!)
            if filteredMessage1 == nil {
                return
            }
        }

        destinationLoop: for destination in destinations {
            var filteredMessage2: Message? = filteredMessage1
            for filter in destination.filters {
                filteredMessage2 = filter(filteredMessage2!)
                if filteredMessage2 == nil {
                    continue destinationLoop
                }
            }
            destination.receiveMessage(filteredMessage2!)
        }
    }

    private func fireTriggers(event:Event) {
        for trigger in triggers.values {
            trigger(event)
        }
    }
}

extension Logger {

    public func log(object:AnyObject?, priority:Priority = .debug, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }
}

extension Logger {

    public func debug(object:AnyObject?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func info(object:AnyObject?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func warning(object:AnyObject?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func error(object:AnyObject?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func critical(object:AnyObject?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .critical, source: source, tags: tags, userInfo: userInfo)
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
        get {
            return filename.hashValue ^ function.hashValue ^ line.hashValue
        }
    }
}

public func ==(lhs: Source, rhs: Source) -> Bool {
    return lhs.filename == rhs.filename && lhs.function == rhs.function && lhs.line == rhs.line
}

// MARK: -

public typealias Tags = Set <String>

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
        get {
            return string.hashValue ^ priority.hashValue ^ source.hashValue ^ (timestamp != nil ? timestamp!.hashValue : 0)
        }
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

    public init(object:AnyObject?, priority:Priority, timestamp:Timestamp? = Timestamp(), source:Source, tags:Tags? = nil, userInfo:UserInfo? = nil) {
        self.string = toString(object)
        self.priority = priority
        self.timestamp = timestamp
        self.source = source
        self.tags = tags
        self.userInfo = userInfo
    }
}

// MARK: -

public class Destination {

    public var filters:[Filter] = []

    public init(logger:Logger) {
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
    case messageLogged(Message)
    case shutdown
}

public typealias Trigger = Event -> Void

