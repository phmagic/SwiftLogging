//
//  SwiftLogging+Globals.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/27/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public var logger:Logger! = {
    var logger = Logger()


    // Logging to console.
    let console = ConsoleDestination()
    logger.addDestination("io.schwa.SwiftLogging.console", destination:console)

    // Logging to file.
    let fileDestination = FileDestination()
    fileDestination.filters.append(sensitiveFilter)
    logger.addDestination("io.schwa.SwiftLogging.default-file", destination:fileDestination)

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

    var string = "\n".join(map(items) {
        return "\($0.0): \($0.1!)"
    })

    string = banner(string)


    let message = Message(string:string, priority:.info, source:Source(), tags:Tags([preformattedTag, verboseTag]))
    logger.log(message, immediate:true)


    return logger
}()