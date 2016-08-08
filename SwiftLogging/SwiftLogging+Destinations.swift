//
//  SwiftLogging+Destinations.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

public class CallbackDestination: Destination {
    public var callback: ((Event, String) -> Void)?

    public init(identifier: String, formatter: EventFormatter = terseFormatter, callback: ((Event, String) -> Void)? = nil) {
        self.callback = callback
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    public override func receiveEvent(event: Event) {
        guard case .Formatted(let subject) = event.subject else {
            fatalError("Cannot process unformatted events.")
        }
        let string = subject + "\n"
        callback?(event, string)
    }
}

// MARK: -

public class ConsoleDestination: Destination {
    public init(identifier: String, formatter: EventFormatter = terseFormatter) {
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    public override func receiveEvent(event: Event) {
        dispatch_async(logger.consoleQueue) {
            guard case .Formatted(let subject) = event.subject else {
                fatalError("Cannot process unformatted events.")
            }
            let string = subject
            print(string)
        }
    }
}

// MARK -

public class MemoryDestination: Destination {

    // TODO: Thread safety (HAHA!)

    public internal(set) var events: [Event] = []

    var listeners: NSMapTable = NSMapTable.weakToStrongObjectsMapTable()

    public override func receiveEvent(event: Event) {
        events.append(event)
        typealias Closure = Event -> Void
        for (_, value) in listeners {
            let closureBox = value as! Box <Closure>
            closureBox.value(event)
        }
    }

    public func addListener(listener: AnyObject, closure: Event -> Void) {
        listeners.setObject(Box(closure), forKey: listener)
    }
}

// MARK: -

public class FileDestination: Destination {

    public let url: NSURL

    public let queue = dispatch_queue_create("io.schwa.SwiftLogging.FileDestination", DISPATCH_QUEUE_SERIAL)
    public var open: Bool = false
    var channel: dispatch_io_t?
    let rotations: Int?

    public init(identifier: String, url: NSURL = FileDestination.defaultFileDestinationURL, rotations: Int? = nil, formatter: EventFormatter = preciseFormatter) {
        self.url = url
        self.rotations = rotations
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    public override func startup() throws {
        dispatch_sync(queue) {
            [weak self] in

            guard let strong_self = self else {
                return
            }

            do {
                let path = try Path(strong_self.url)

                if path.parent?.exists == false {
                    try path.parent?.createDirectory(withIntermediateDirectories: true)
                }

                if strong_self.rotations != nil {
                    try path.rotate(limit: strong_self.rotations)
                }

                strong_self.channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, strong_self.url.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0o600, strong_self.queue) {
                    (error: Int32) -> Void in
                    if error != 0 {
                        strong_self.logger.internalLog("ERROR: \(error)")
                    }
                }
                if strong_self.channel != nil {
                    strong_self.open = true
                }
            }
            catch let error {
                strong_self.logger.internalLog("Failed to start FileDestination: \(error)")
            }
        }
    }

    public override func shutdown() throws {
        dispatch_sync(queue) {
            [unowned self] in
            self.open = false
            if let channel = self.channel {
                dispatch_io_close(channel, 0)
            }
        }
    }

    public override func receiveEvent(event: Event) {
        dispatch_async(queue) {
            [weak self] in

            guard let strong_self = self else {
                return
            }

            if strong_self.open == false {
                return
            }

            guard case .Formatted(let subject) = event.subject else {
                fatalError("Cannot process unformatted events.")
            }
            let string = subject + "\n"
            let data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
            // DISPATCH_DATA_DESTRUCTOR_DEFAULT is missing in swiff
            let dispatchData = dispatch_data_create(data.bytes, data.length, strong_self.queue, nil)

            guard let channel = strong_self.channel else {
                fatalError("Trying to write log data but channel unavailable")
            }

            dispatch_io_write(channel, 0, dispatchData, strong_self.queue) {
                _ -> Void in

                // TODO: This left intentionally blank?
            }
        }
    }

    public override func flush() {
        flush(nil)
    }

    public func flush(callback: ((NSURL) -> Void)?) {
        dispatch_sync(queue) {
            [weak self] in
            
            guard let strong_self = self else {
                return
            }

            guard let channel = strong_self.channel else {
                fatalError("Trying to flush but channel unavailable")
            }

            let descriptor = dispatch_io_get_descriptor(channel)
            fsync(descriptor)
            
            callback?(strong_self.url)
        }
    }

    public static var defaultFileDestinationURL: NSURL {
        let bundle = NSBundle.mainBundle()
        // If we're in a bundle: use ~/Library/Application Support/<bundle identifier>/<bundle name>.log
        if let bundleIdentifier = bundle.bundleIdentifier, let bundleName = bundle.infoDictionary?["CFBundleName"] as? String {
            let url = try! NSFileManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            return url.URLByAppendingPathComponent("\(bundleIdentifier)/Logs/\(bundleName).log")!
        }
        // Otherwise use ~/Library/Logs/<process name>.log
        else {
            let processName = (Process.arguments.first! as NSString).pathComponents.last!
            var url = try! NSFileManager().URLForDirectory(.LibraryDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            url = url.URLByAppendingPathComponent("Logs")!
            try! NSFileManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            url = url.URLByAppendingPathComponent("\(processName).log")!
            return url
        }
    }

}
