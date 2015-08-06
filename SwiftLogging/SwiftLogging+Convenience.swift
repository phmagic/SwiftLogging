//
//  SwiftLogging+Convenience.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

extension Logger {

    public func debug(object:Any?, tags:[String]? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let tags:Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(object: object, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func info(object:Any?, tags:[String]? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let tags:Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(object: object, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func warning(object:Any?, tags:[String]? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let tags:Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(object: object, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func error(object:Any?, tags:[String]? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let tags:Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(object: object, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }

    public func critical(object:Any?, tags:[String]? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let tags:Tags? = tags != nil ? Tags(tags!) : nil
        let event = Event(object: object, priority: .critical, source: source, tags: tags, userInfo: userInfo)
        log(event)
    }
}
