//
//  SwiftLogging+Formatters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

extension Priority {
    var toEmoji: String {
        switch self {
            case .Debug:
                return "👷"
            case .Info:
                return "📰"
            case .Warning:
                return "🚧"
            case .Error:
                return "🚨"
            case .Critical:
                return "💣"
        }
    }
}

// MARK: -

public func preciseFormatter(event: Event) -> String {

    let subject: String = event.subject != nil ? String(event.subject!) : "nil"
    

    let string = subject.escape(asASCII: false, extraCharacters: NSCharacterSet.newlineCharacterSet())
    return "\(event.timestamp!) \(event.priority) \(event.source): \(string)"
}

public func terseFormatter(event: Event) -> String {

    let subject: String = event.subject != nil ? String(event.subject!) : "nil"

    if let tags = event.tags where tags.contains(preformattedTag) {
        return subject
    }

    return "\(event.timestamp!.toTimeString) \(event.priority.toEmoji) [\(event.source)]: \(subject)"
}

