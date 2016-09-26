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
            case .debug:
                return "👷"
            case .info:
                return "📰"
            case .warning:
                return "🚧"
            case .error:
                return "🚨"
            case .critical:
                return "💣"
        }
    }
}

// MARK: -

public func preciseFormatter(_ event: Event) -> String {
    guard case .raw(let subject) = event.subject else {
        fatalError("Cannot format an already formatted subject.")
    }

    let stringSubject: String = subject != nil ? String(describing: subject!) : "nil"
    let string = stringSubject.escape(asASCII: false, extraCharacters: CharacterSet.newlines)
    return "\(event.timestamp!) \(event.priority) \(event.source): \(string)"
}

public func terseFormatter(_ event: Event) -> String {
    guard case .raw(let subject) = event.subject else {
        fatalError("Cannot format an already formatted subject.")
    }

    let stringSubject: String = subject != nil ? String(describing: subject!) : "nil"
    if let tags = event.tags , tags.contains(preformattedTag) {
        return stringSubject
    }
    return "\(event.timestamp!.toTimeString) \(event.priority.toEmoji) [\(event.source)]: \(stringSubject)"
}
