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
    logger.addDestination("console", destination:ConsoleDestination(logger:logger))
    logger.addDestination("default-file", destination:FileDestination(logger:logger))
    return logger
}()