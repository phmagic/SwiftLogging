//
//  Events.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

public struct EventBroadcaster <Event:Hashable> {

    public typealias Key = String
    public typealias Handler = (Event, Any?) -> Void

    var eventsByKey:[Key:Event] = [:]
    var handlersByKey:[Key:Handler] = [:]
    var keysByEvent:[Event:Set <Key>] = [:]

    public mutating func addHandler(key:Key, event:Event, handler:Handler) {
        handlersByKey[key] = handler
        eventsByKey[key] = event

        var keys = keysByEvent[event] ?? Set <Key> ()
        keys.insert(key)
        keysByEvent[event] = keys
    }

    public mutating func removeHandler(key:Key, event:Event) {
        handlersByKey.removeValueForKey(key)
        eventsByKey.removeValueForKey(key)

        var keys = keysByEvent[event]
        keys!.remove(key)
        keysByEvent[event] = keys
    }

    public mutating func removeHandler(key:Key) {
        let event = eventsByKey[key]
        removeHandler(key, event: event!)
    }

    public func fireHandlers(event:Event, object:Any? = nil) {
        if let keys = keysByEvent[event] {
            for key in keys {
                let handler = handlersByKey[key]
                handler?(event, object)
            }
        }
    }
}
