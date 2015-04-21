//
//  SwiftLogging+Destinations.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/6/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

public class ConsoleDestination: Destination {
    let queue = dispatch_queue_create("io.schwa.SwiftLogging.ConsoleDestination", DISPATCH_QUEUE_SERIAL)

    public override func receiveMessage(message:Message) {
        dispatch_async(queue) {
            Swift.println(message)
        }
    }
}

// MARK: -

public class FileDestination: Destination {

    let url:NSURL
    let queue = dispatch_queue_create("io.schwa.SwiftLogging.FileDestination", DISPATCH_QUEUE_SERIAL)
    var channel:dispatch_io_t!
    var open:Bool = false

    init?(logger: Logger, url:NSURL) {
        self.url = url
        super.init(logger: logger)
    }

    public override func startup() {
        self.channel = dispatch_io_create_with_path(DISPATCH_IO_STREAM, self.url.fileSystemRepresentation, O_CREAT | O_WRONLY | O_APPEND, 0o600, queue) {
            (error:Int32) -> Void in
//            println("ERROR: \(error)")
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

                let messageString = "\(message)\n"
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
}

// MARK: -

//extension Priority {
//    var aslLevel:Int32 {
//        get {
//            switch self {
//                case .debug:
//                    return ASL_LEVEL_DEBUG
//                case .info:
//                    return ASL_LEVEL_INFO
//                case .warning:
//                    return ASL_LEVEL_WARNING
//                case .error:
//                    return ASL_LEVEL_ERR
//                case .critical:
//                    return ASL_LEVEL_CRIT
//            }
//        }
//    }
//}
//
//
//public class ASLDestination: Destination {
//
//    let queue = dispatch_queue_create("io.schwa.SwiftLogging.ASLDestination", DISPATCH_QUEUE_SERIAL)
//
////    var client:COpaquePointer
//
////    init() {
//////        client = asl_open("test", "test", 0)
//////        println(client.dynamicType)
////    }
//
//    public override  func receiveMessage(message:Message) {
//        dispatch_async(queue) {
//            my_asl_log_message(message.priority.aslLevel, "\(message)")
//        }
//    }
//}
