//
//  SwiftLogging+Globals.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/27/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftLogging

public var log: Logger = {
    var logger = SwiftLogging.log

    // Logging to console.
    let console = ConsoleDestination(identifier: "io.schwa.SwiftLogging.console")
    logger.addDestination(console)

    // Add source filter
    console.addFilter(key: "?", filter: sourceFilter(pattern: ".*"))

//    // Add duplications filter
//    console.addFilter(duplicatesFilter(timeout: 5.0))

    // Add verbosity filter
    console.addFilter(key: "verbosity", filter: verbosityFilter())

    // Logging to file.
    let fileDestination = FileDestination(identifier: "io.schwa.SwiftLogging.default-file")
    fileDestination.addFilter(key: "sensitivity", filter: sensitivityFilter)
    logger.addDestination(fileDestination)

//    // MOTD
//    let infoDictionary = Bundle.main.infoDictionary!
//    let processInfo = ProcessInfo.processInfo
//    var items: [(String, Any?)] = [
//        ("App Name", infoDictionary["CFBundleName"] ?? "?"),
//        ("App Identifier", infoDictionary["CFBundleIdentifier"] ?? "?"),
//        ("App Version", infoDictionary["CFBundleVersion"] ?? "?"),
//        ("App Version", infoDictionary["CFBundleShortVersionString"] ?? "?"),
//        ("Operating System", processInfo.operatingSystemVersionString),
//        ("PID", "\(processInfo.processIdentifier)"),
//        ("Hostname", "\(processInfo.hostName)"),
//        ("Locale", NSLocale.current.identifier),
//    ]
//    logger.motd(items, priority: .info, tags: Tags([preformattedTag, verboseTag]))

    return logger
}()

