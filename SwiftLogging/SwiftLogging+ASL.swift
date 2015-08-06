//
//  SwiftLogging+ASL.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 5/15/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation

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
//    public override  func receiveEvent(event:Event) {
//        dispatch_async(queue) {
//            my_asl_log_message(event.priority.aslLevel, "\(event)")
//        }
//    }
//}
//
