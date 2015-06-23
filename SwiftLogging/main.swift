//
//  main.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 4/21/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation


logger.addFilter("sensitiveFilter", filter: sensitiveFilter)
logger.addFilter("duplicateFilter", filter: duplicateFilter())


logger.debug("My password is \"123456\"", tags:Tags([sensitiveTag]))

for R in 0..<10 {

    usleep(useconds_t(5.0 * 1000000))

    for N in 0..<5000 {
        logger.info("Hello world")
    //    usleep(useconds_t(0.1 * 1000000))
    }
}

logger.info("Done")

logger.shutdown()

usleep(useconds_t(0.5 * 1000000))

//dispatch_main()

