//
//  SwiftLogging+Destinations.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public class ConsoleDestination: Destination {
    public let formatter:EventFormatter

    public init(formatter:EventFormatter = terseFormatter) {
        self.formatter = formatter
    }

    public override func receiveEvent(event:Event) {
        dispatch_async(logger.consoleQueue) {
            [weak self] in
            if let strong_self = self {
                let string = strong_self.formatter(event)
                print(string)
            }
        }
    }
}

// MARK -

public class MemoryDestination: Destination {
    public internal(set) var events:[Event] = []

    public override func receiveEvent(event:Event) {
        events.append(event)
    }
}

// MARK: -

public class FileDestination: Destination {

    public let url:NSURL
    public let formatter:EventFormatter

    public let queue = dispatch_queue_create("io.schwa.SwiftLogging.FileDestination", DISPATCH_QUEUE_SERIAL)
    public var open:Bool = false
    var channel:dispatch_io_t!

    public init(url:NSURL = FileDestination.defaultFileDestinationURL, formatter:EventFormatter = preciseFormatter) {
        self.url = url
        self.formatter = formatter
        super.init()
    }

    public override func startup() {
        dispatch_async(queue) {
            [weak self] in

            if let strong_self = self {
                let parentURL = strong_self.url.URLByDeletingLastPathComponent!
                if NSFileManager().fileExistsAtPath(parentURL.path!) == false {
                    try! NSFileManager().createDirectoryAtURL(parentURL, withIntermediateDirectories: true, attributes: nil)
                }
                strong_self.channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, strong_self.url.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0o600, strong_self.queue) {
                    (error:Int32) -> Void in
                    if error != 0 {
                        strong_self.logger.internalLog("ERROR: \(error)")
                    }
                }
                if strong_self.channel != nil {
                    strong_self.open = true
                }
            }
        }
    }

    public override func shutdown() {
        dispatch_async(queue) {
            [unowned self] in
            self.open = false
            dispatch_io_close(self.channel, 0)
        }
    }

    public override func receiveEvent(event:Event) {
        dispatch_async(queue) {
            [weak self] in

            if let strong_self = self {
                if strong_self.open == false {
                    return
                }

                let string = strong_self.formatter(event) + "\n"
                let data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                // DISPATCH_DATA_DESTRUCTOR_DEFAULT is missing in swiff
                let dispatchData = dispatch_data_create(data.bytes, data.length, strong_self.queue, nil)

                dispatch_io_write(strong_self.channel, 0, dispatchData, strong_self.queue) {
                    (done:Bool, data:dispatch_data_t!, error:Int32) -> Void in
                }
            }
        }
    }

    public override func flush() {
        dispatch_barrier_async(queue) {
            [weak self] in

            if let strong_self = self {
                let descriptor = dispatch_io_get_descriptor(strong_self.channel)
                fsync(descriptor)
            }
        }
    }

    public static var defaultFileDestinationURL:NSURL {
        let bundle = NSBundle.mainBundle()
        // If we're in a bundle: use ~/Library/Application Support/<bundle identifier>/<bundle name>.log
        if let bundleIdentifier = bundle.bundleIdentifier, let bundleName = bundle.infoDictionary?["CFBundleName"] as? String {
            let url = try! NSFileManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            return url.URLByAppendingPathComponent("\(bundleIdentifier)/Logs/\(bundleName).log")
        }
        // Otherwise use ~/Library/Logs/<process name>.log
        else {
            let processName = (Process.arguments.first! as NSString).pathComponents.last!
            var url = try! NSFileManager().URLForDirectory(.LibraryDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            url = url.URLByAppendingPathComponent("Logs")
            try! NSFileManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            url = url.URLByAppendingPathComponent("\(processName).log")
            return url
        }
    }

}
