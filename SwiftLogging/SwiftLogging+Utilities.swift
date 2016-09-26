//
//  SwiftLogging+Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 10/19/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public extension Logger {

    func motd(_ values: [(String, Any?)], priority: Priority, source: Source = Source(), tags: Tags = Tags([preformattedTag, verboseTag])) {

        let values = values.filter() {
            $1 != nil
        }
        var string = values.map() {
            return "\($0.0): \($0.1!)"
        }.joined(separator: "\n")

        string = banner(string)

        let event = Event(subject: string, priority: priority, source: source, tags: tags)
        log(event, immediate: true)
    }

}
