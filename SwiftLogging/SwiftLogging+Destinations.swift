//
//  SwiftLogging+Destinations.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public class ConsoleDestination: Destination {
    public let formatter:MessageFormatter

    let queue = dispatch_queue_create("io.schwa.SwiftLogging.ConsoleDestination", DISPATCH_QUEUE_SERIAL)

    init(logger:Logger, formatter:MessageFormatter = simpleFormatter) {
        self.formatter = formatter
        super.init(logger:logger)
    }

    public override func receiveMessage(message:Message) {
        dispatch_async(queue) {
            let string = simpleFormatter(message)
            Swift.println(string)
        }
    }
}

// MARK: -

public class FileDestination: Destination {

    public let url:NSURL
    public let formatter:MessageFormatter

    let queue = dispatch_queue_create("io.schwa.SwiftLogging.FileDestination", DISPATCH_QUEUE_SERIAL)
    var channel:dispatch_io_t!
    var open:Bool = false

    init(logger: Logger, url:NSURL = FileDestination.defaultFileDestinationURL, formatter:MessageFormatter = simpleFormatter) {
        self.url = url
        self.formatter = formatter
        super.init(logger: logger)
    }

    public override func startup() {

        let parentURL = url.URLByDeletingLastPathComponent!

        if parentURL.checkPromisedItemIsReachableAndReturnError(nil) == false {
            let fileManager = NSFileManager()
            fileManager.createDirectoryAtURL(parentURL, withIntermediateDirectories: true, attributes: nil, error: nil)
        }

        self.channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, url.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0o600, queue) {
            (error:Int32) -> Void in
            println("ERROR: \(error)")
        }
        if self.channel != nil {
            self.open = true
        }
    }

    public override func shutdown() {
        dispatch_sync(queue) {
            [unowned self] in
            self.open = false
            dispatch_io_close(self.channel, 0)
        }
    }

    public override func receiveMessage(message:Message) {
        dispatch_async(queue) {
            [weak self] in

            if let strong_self = self {
                if strong_self.open == false {
                    return
                }

                let string = simpleFormatter(message)
                let messageString = "\(string)\n"
                var data = (messageString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                // DISPATCH_DATA_DESTRUCTOR_DEFAULT is missing in swiff
                let dispatchData = dispatch_data_create(data.bytes, data.length, strong_self.queue, nil)

                dispatch_io_write(strong_self.channel, 0, dispatchData, strong_self.queue) {
                    (done:Bool, data:dispatch_data_t!, error:Int32) -> Void in
//                    println((done, data, error))
                }
            }
        }
    }

    public static var defaultFileDestinationURL:NSURL {
        get {
            let fileManager = NSFileManager()
            var url = fileManager.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)!


            let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!

            let bundleName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as! String


            url = url.URLByAppendingPathComponent("\(bundleIdentifier)/Logs/\(bundleName).log")
            println(url)

            return url

        }
    }

}
