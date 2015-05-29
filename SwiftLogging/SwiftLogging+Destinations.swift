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

    init(formatter:MessageFormatter = terseFormatter) {
        self.formatter = formatter
    }

    public override func receiveMessage(message:Message) {
        dispatch_async(logger.consoleQueue) {
            let string = self.formatter(message)
            println(string)
        }
    }
}

// MARK -

public class MemoryDestination: Destination {
    public internal(set) var messages:[Message] = []

    public override func receiveMessage(message:Message) {
        messages.append(message)
    }
}

// MARK: -

public class FileDestination: Destination {

    public let url:NSURL
    public let formatter:MessageFormatter

    let queue = dispatch_queue_create("io.schwa.SwiftLogging.FileDestination", DISPATCH_QUEUE_SERIAL)
    var channel:dispatch_io_t!
    var open:Bool = false

    init(url:NSURL = FileDestination.defaultFileDestinationURL, formatter:MessageFormatter = preciseFormatter) {
        self.url = url
        self.formatter = formatter
        super.init()
    }

    public override func startup() {

        let parentURL = url.URLByDeletingLastPathComponent!

        if parentURL.checkPromisedItemIsReachableAndReturnError(nil) == false {
            let fileManager = NSFileManager()
            fileManager.createDirectoryAtURL(parentURL, withIntermediateDirectories: true, attributes: nil, error: nil)
        }

        self.channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, url.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0o600, queue) {
            (error:Int32) -> Void in
            self.logger.internalLog("ERROR: \(error)")
        }
        if self.channel != nil {
            self.open = true
        }

        logger.internalLog("Startup Done")
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
                    strong_self.logger.internalLog("File not open, skipping")
                    return
                }

                let string = strong_self.formatter(message)
                let messageString = "\(string)\n"
                var data = (messageString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                // DISPATCH_DATA_DESTRUCTOR_DEFAULT is missing in swiff
                let dispatchData = dispatch_data_create(data.bytes, data.length, strong_self.queue, nil)

                dispatch_io_write(strong_self.channel, 0, dispatchData, strong_self.queue) {
                    (done:Bool, data:dispatch_data_t!, error:Int32) -> Void in
                    strong_self.logger.internalLog(("dispatch_io_write", done, data, error))

                }
            }
        }
    }

    public static var defaultFileDestinationURL:NSURL {
        let fileManager = NSFileManager()
        var url = fileManager.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)!
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        let bundleName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as! String
        url = url.URLByAppendingPathComponent("\(bundleIdentifier)/Logs/\(bundleName).log")
        return url
    }

}
