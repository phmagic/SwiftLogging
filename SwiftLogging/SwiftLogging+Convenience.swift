//
//  SwiftLogging+Convenience.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

extension Logger {

    public func log(subject: Any?, priority: Priority = .Debug, tags: Tags? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let event = Event(subject: subject, priority: priority, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    // Priority based logging

    public func debug(subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .Debug, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func info(subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .Info, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func warning(subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .Warning, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func error(subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .Error, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func critical(subject: Any?, tags: [String]? = nil, userInfo: UserInfo? = nil, filename: String = #file, function: String = #function, line: Int = #line) {
        let source = Source(filename: filename, function: function, line: line)
        let tags: Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(subject: subject, priority: .Critical, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }
}
