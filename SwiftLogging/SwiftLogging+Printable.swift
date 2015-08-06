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
        return "\(timestamp!) \(priority) \(source) \(string)"
    }
}

extension Priority {
    public var toString:String {
        switch self {
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .warning:
                return "warning"
            case .error:
                return "error"
            case .critical:
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
