//
//  SwiftLogging+Formatters.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation


//public func simpleFormatter(message:Message) -> String {
//
//    if let tags = message.tags where tags.contains(preformattedTag) {
//        return message.string
//    }
//
//    return "\(message.timestamp!) \(message.priority) \(message.source): \(message.string)"
//}

extension Priority {
    var toEmoji:String {
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


public func preciseFormatter(message:Message) -> String {
    let string = message.string.escape(asASCII: false, extraCharacters: NSCharacterSet.newlineCharacterSet())
    return "\(message.timestamp!) \(message.priority) \(message.source): \(string)"
}


public func terseFormatter(message:Message) -> String {

    if let tags = message.tags where tags.contains(preformattedTag) {
        return message.string
    }

    return "\(message.timestamp!.toTimeString) \(message.priority.toEmoji) [\(message.source)]: \(message.string)"
}

