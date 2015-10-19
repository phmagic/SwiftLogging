//
//  main.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 4/21/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation


log.addFilter("sensitiveFilter", filter: sensitiveFilter)
log.addFilter("duplicateFilter", filter: duplicateFilter())
log.addFilter("duplicateFilter", filter: verbosityFilter())


log.debug("My password is \"123456\"", tags: [sensitiveTag])

log.debug("Blah blah", tags: [verboseTag])


for R in 0..<10 {

    usleep(useconds_t(5.0 * 100000))

    for N in 0..<5000 {
        log.info("Hello world")
    //    usleep(useconds_t(0.1 * 1000000))
    }
}

log.info("Done")

log.shutdown()

usleep(useconds_t(0.5 * 1000000))

//dispatch_main()

