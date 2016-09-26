//
//  SwiftLogging+Convenience.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

extension Logger {

    public func log(_ subject: Any?, priority: Priority = .debug, tags: Tags? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let event = Event(subject: subject, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    // Priority based logging

    public func debug(_ subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func info(_ subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func warning(_ subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func error(_ subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func critical(_ subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .critical, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }
}
