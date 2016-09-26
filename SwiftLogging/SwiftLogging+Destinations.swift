//
//  SwiftLogging+Destinations.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

open class CallbackDestination: Destination {
    open var callback: ((Event, String) -> Void)?

    public init(identifier: String, formatter: @escaping EventFormatter = terseFormatter, callback: ((Event, String) -> Void)? = nil) {
        self.callback = callback
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    open override func receiveEvent(_ event: Event) {
        guard case .formatted(let subject) = event.subject else {
            fatalError("Cannot process unformatted events.")
        }
        let string = subject + "\n"
        callback?(event, string)
    }
}

// MARK: -

open class ConsoleDestination: Destination {
    public init(identifier: String, formatter: @escaping EventFormatter = terseFormatter) {
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    open override func receiveEvent(_ event: Event) {
        logger.consoleQueue.async {
            guard case .formatted(let subject) = event.subject else {
                fatalError("Cannot process unformatted events.")
            }
            let string = subject
            print(string)
        }
    }
}

// MARK -

open class MemoryDestination: Destination {

    // TODO: Thread safety (HAHA!)

    open internal(set) var events: [Event] = []

    public typealias Closure = (Event) -> Void

    private typealias BoxedClosure = Box <Closure>
    private var listeners = NSMapTable <AnyObject, BoxedClosure> (keyOptions: [.weakMemory, .objectPersonality], valueOptions: [.strongMemory, .objectPersonality])

    open override func receiveEvent(_ event: Event) {
        events.append(event)

        for object in listeners.objectEnumerator()! {
            let closureBox = object as! Box <Closure>
            closureBox.value(event)
        }
    }

    open func addListener(_ listener: AnyObject, closure: @escaping Closure) {
        let box = BoxedClosure(closure)
        listeners.setObject(box, forKey: listener)
    }
}

// MARK: -

open class FileDestination: Destination {

    open let url: URL

    open let queue = DispatchQueue(label: "io.schwa.SwiftLogging.FileDestination", attributes: [])
    open var open: Bool = false
    var channel: DispatchIO?
    let rotations: Int?

    public init(identifier: String, url: URL = FileDestination.defaultFileDestinationURL, rotations: Int? = nil, formatter: @escaping EventFormatter = preciseFormatter) {
        self.url = url
        self.rotations = rotations
        super.init(identifier: identifier)
        self.formatter = formatter
    }

    open override func startup() throws {
        queue.sync {
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

                strong_self.channel = strong_self.url.withUnsafeFileSystemRepresentation() {
                    pathRepresentation in

                    return DispatchIO(type: .stream, path: pathRepresentation!, oflag: O_CREAT | O_WRONLY | O_APPEND, mode: 0o600, queue: strong_self.queue) {
                        (error: Int32) -> Void in
                        if error != 0 {
                            strong_self.logger.internalLog("ERROR: \(error)")
                        }
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

    open override func shutdown() throws {
        queue.sync {
            [unowned self] in
            self.open = false
            if let channel = self.channel {
                channel.close(flags: DispatchIO.CloseFlags(rawValue: UInt(0)))
            }
        }
    }

    open override func receiveEvent(_ event: Event) {
        queue.async {
            [weak self] in

            guard let strong_self = self else {
                return
            }

            if strong_self.open == false {
                return
            }

            guard case .formatted(let subject) = event.subject else {
                fatalError("Cannot process unformatted events.")
            }
            let string = subject + "\n"
            let data = string.data(using: String.Encoding.utf8)!
            // DISPATCH_DATA_DESTRUCTOR_DEFAULT is missing in swiff

            let dispatchData = DispatchData(data: data)

            guard let channel = strong_self.channel else {
                fatalError("Trying to write log data but channel unavailable")
            }

            channel.write(offset: 0, data: dispatchData, queue: strong_self.queue) {
                _ -> Void in

                // TODO: This left intentionally blank?
            }
        }
    }

    open override func flush() {
        flush(nil)
    }

    open func flush(_ callback: ((URL) -> Void)?) {
        queue.sync {
            [weak self] in
            
            guard let strong_self = self else {
                return
            }

            guard let channel = strong_self.channel else {
                fatalError("Trying to flush but channel unavailable")
            }

            let descriptor = channel.fileDescriptor
            fsync(descriptor)
            
            callback?(strong_self.url)
        }
    }

    open static var defaultFileDestinationURL: URL {
        let bundle = Bundle.main
        // If we're in a bundle: use ~/Library/Application Support/<bundle identifier>/<bundle name>.log
        if let bundleIdentifier = bundle.bundleIdentifier, let bundleName = bundle.infoDictionary?["CFBundleName"] as? String {
            let url = try! FileManager().url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return url.appendingPathComponent("\(bundleIdentifier)/Logs/\(bundleName).log")
        }
        // Otherwise use ~/Library/Logs/<process name>.log
        else {
            let processName = (CommandLine.arguments.first! as NSString).pathComponents.last!
            var url = try! FileManager().url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url = url.appendingPathComponent("Logs")
            try! FileManager().createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            url = url.appendingPathComponent("\(processName).log")
            return url
        }
    }

}
