//
//  SwiftLogging+Printable.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

extension Event: Printable {
    public var description:String {
        return "\(timestamp!) \(priority) \(source) \(subject)"
    }
}

extension Priority {
    public var toString:String {
        switch self {
            case .Debug:
                return "debug"
            case .Info:
                return "info"
            case .Warning:
                return "warning"
            case .Error:
                return "error"
            case .Critical:
                return "critical"
        }
    }
}

extension Priority: Printable {
    public var description:String {
        return toString
    }
}

extension Source: Printable {
    public var description: String {
        return toString
    }
}

extension Source {
    public var toString: String {
        let lastPathComponent = (filename as NSString).lastPathComponent
        return "\(lastPathComponent):\(line) \(function)"
    }
}
