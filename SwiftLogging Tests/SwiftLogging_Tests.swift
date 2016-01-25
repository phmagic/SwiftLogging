//
//  SwiftLogging_Tests.swift
//  SwiftLogging Tests
//
//  Created by Jonathan Wight on 5/28/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Cocoa
import XCTest
import SwiftLogging

class SwiftLogging_Tests: XCTestCase {
    
    func testAddingAndRemovingFilters() {
        let logger = Logger()
        XCTAssert(logger.filters.count == 0)
        logger.addFilter("test", filter: nilFilter)
        print(logger.filters)
        XCTAssert(logger.filters.count == 1)
        logger.removeFilter("test")
        XCTAssert(logger.filters.count == 0)
    }

    /**
     Test filters dropping events.
     
     Note we have to construct a Event manually and call log() with immedate: true to prevent the operation from being deferred.
     */
    func testFilters() {
        let logger = Logger()
        let memoryDestination = MemoryDestination()
        logger.addDestination("memory", destination: memoryDestination)

        XCTAssert(memoryDestination.events.count == 0)

        logger.log(Event(subject: 1, priority: .Debug, source: Source()), immediate: true)

        XCTAssert(memoryDestination.events.count == 1)

        logger.addFilter("test", filter: nilFilter)

        logger.log(Event(subject: 2, priority: .Debug, source: Source()), immediate: true)

        XCTAssert(memoryDestination.events.count == 1)
    }
}
