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

    public var destinations:[Destination] = []
    public var filters:[(String,Filter)] = []
    public var triggers:[String:Trigger] = [:]

    private let startTimestamp:Timestamp = Timestamp()
    private let queue = dispatch_queue_create("io.schwa.SwiftLogger", DISPATCH_QUEUE_SERIAL)
    private var count:Int64 = 0
    private var running:Bool = false

    public init(defaultConfig:Bool = true) {
        if defaultConfig == true {
            destinations.append(ConsoleDestination(logger:self))
            destinations.append(FileDestination(logger:self, url:NSURL(fileURLWithPath: "/Users/schwa/Desktop/Test.log")!)!)
//            destinations.append(ASLDestination(logger:self))
        }
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

public var logger:Logger! = Logger()

extension Logger {

    public func log(string:String, priority:Priority = .debug, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func debug(string:String, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func info(string:String, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func warning(string:String, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func error(string:String, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func critical(string:String, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(string: string, priority: .critical, source: source, tags: tags, userInfo: userInfo)
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

extension Priority {
    public var toString:String {
        get {
            switch self {
                case .debug:
                    return "debug"
                case .info:
                    return "info"
                case .warning:
                    return "warning"
                case .error:
                    return "error"
                case .critical:
                    return "critical"
            }
        }
    }
}

extension Priority: Printable {
    public var description:String {
        get {
            return toString
        }
    }
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

extension Source {
    public var toString: String {
        get {
            let lastPathComponent = (filename as NSString).lastPathComponent
            return "\(lastPathComponent):\(line) \(function)"
        }
    }
}

extension Source: Printable {
    public var description: String {
        get {
            return toString
        }
    }
}

// MARK: -

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

private let iso8601Formatter:NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSXX"
//    dateFormatter.timeZone = NSTimeZone(name:"UTC")
    return dateFormatter
    }()

extension Timestamp {
    public var toString: String {
        get {
            let date = NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
            let string = iso8601Formatter.stringFromDate(date)
            return string
        }
    }
}

extension Timestamp: Printable {
    public var description: String {
        get {
            return toString
        }
    }
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

    public init(message:Message, timestamp:Timestamp?) {
        self.string = message.string
        self.priority = message.priority
        self.timestamp = timestamp
        self.source = message.source
        self.tags = message.tags
        self.userInfo = message.userInfo
    }
}

extension Message: Printable {
    public var description:String {
        get {
            return "\(timestamp!) \(priority) \(source) \(string)"
        }
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

extension Event: Printable {
    public var description:String {
        get {
            switch self {
                case .startup:
                    return "startup"
                case .messageLogged:
                    return "messageLogged"
                case .shutdown:
                    return "shutdown"
            }
        }
    }
}

public typealias Trigger = Event -> Void

