//
//  SwiftLogging+Convenience.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

extension Logger {

    public func debug(object:Any?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .debug, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func info(object:Any?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .info, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func warning(object:Any?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .warning, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func error(object:Any?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .error, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }

    public func critical(object:Any?, tags:Tags? = nil, userInfo:UserInfo? = nil, filename:String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        let source = Source(filename: filename, function: function, line: line)
        let message = Message(object: object, priority: .critical, source: source, tags: tags, userInfo: userInfo)
        log(message)
    }
}
