//
//  SwiftLogging+Formatters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public extension Priority {
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
    guard case .Raw(let subject) = event.subject else {
        fatalError("Cannot format an already formatted subject.")
    }

    let stringSubject: String = subject != nil ? String(subject!) : "nil"
    let string = stringSubject.escape(asASCII: false, extraCharacters: NSCharacterSet.newlineCharacterSet())
    return "\(event.timestamp!) \(event.priority) \(event.source): \(string)"
}

public func terseFormatter(event: Event) -> String {
    guard case .Raw(let subject) = event.subject else {
        fatalError("Cannot format an already formatted subject.")
    }

    let stringSubject: String = subject != nil ? String(subject!) : "nil"
    if let tags = event.tags where tags.contains(preformattedTag) {
        return stringSubject
    }
    return "\(event.timestamp!.toTimeString) \(event.priority.toEmoji) [\(event.source)]: \(stringSubject)"
}
