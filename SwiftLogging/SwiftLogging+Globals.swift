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
    let console = ConsoleDestination()
    console.addFilter(sourceFilter())
    logger.addDestination("io.schwa.SwiftLogging.console", destination: console)

    // Logging to file.
    let fileDestination = FileDestination()
    fileDestination.addFilter(sensitivityFilter)
    logger.addDestination("io.schwa.SwiftLogging.default-file", destination: fileDestination)

    // MOTD
    let infoDictionary = NSBundle.mainBundle().infoDictionary!
    let processInfo = NSProcessInfo.processInfo()
    var items = [
        ("App Name", infoDictionary["CFBundleName"] ?? "?"),
        ("App Identifier", infoDictionary["CFBundleIdentifier"] ?? "?"),
        ("App Version", infoDictionary["CFBundleVersion"] ?? "?"),
        ("App Version", infoDictionary["CFBundleShortVersionString"] ?? "?"),
        ("Operating System", processInfo.operatingSystemVersionString),
        ("PID", "\(processInfo.processIdentifier)"),
        ("Hostname", "\(processInfo.hostName)"),
        ("Locale", NSLocale.currentLocale().localeIdentifier),
    ]

    logger.motd(items, priority: .Info, tags: Tags([preformattedTag, verboseTag]))

    return logger
}()

