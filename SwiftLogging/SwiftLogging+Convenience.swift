//
//  SwiftLogging+Convenience.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

extension Logger {

    public func log(_ items: Any..., separator: String = " ", priority: Priority = .debug, tags: Tags? = nil, userInfo: UserInfo? = nil, source: Source) {
        let event = Event(items: items, separator: separator, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    
    public func log(_ items: Any..., separator: String = " ", priority: Priority = .debug, tags: Tags? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let event = Event(items: items, separator: separator, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    // Priority based logging

    public func debug(_ items: Any..., separator: String = " ", tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(items: items, separator: separator, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    public func info(_ items: Any..., separator: String = " ", tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(items: items, separator: separator, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    public func warning(_ items: Any..., separator: String = " ", tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(items: items, separator: separator, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    public func error(_ items: Any..., separator: String = " ", tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(items: items, separator: separator, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }

    public func critical(_ items: Any..., separator: String = " ", tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(items: items, separator: separator, priority: .critical, source: source, tags: tags, userInfo: userInfo)
        log(event: event)
    }
}
