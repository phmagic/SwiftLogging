//
//  DataDestination.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import SwiftLogging

import SwiftUtilities

public class DataDestination: Destination {

    public struct Datum {
        public let key: String
        public var lastValue: Any
        public var count: Int
    }

    public private(set) var data = Dictionary <String, Datum> ()

    public private(set) var listeners: NSMapTable = NSMapTable.weakToStrongObjectsMapTable()

    public func addListener(listener: AnyObject, closure: Datum -> Void) {
        listeners.setObject(Box(closure), forKey: listener)
    }

    public override func receiveEvent(event: Event) {
        guard let subject = event.subject as? KeyValue else {
            return
        }
        var datum: Datum! = data[subject.key]
        if datum == nil {
            datum = Datum(key: subject.key, lastValue: subject.value, count: 1)
        }
        else {
            datum.count = datum.count + 1
            datum.lastValue = subject.value
        }
        data[subject.key] = datum

        typealias Closure = Datum -> Void
        for (_, value) in listeners {
            let closureBox = value as! Box <Closure>
            closureBox.value(datum)
        }
    }
}

struct KeyValue {
    var key: String
    var value: Any
}