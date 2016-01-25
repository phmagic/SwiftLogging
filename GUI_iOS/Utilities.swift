//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation
import UIKit

class DispatchQueue {

    let queue: dispatch_queue_t

    init(queue: dispatch_queue_t) {
        self.queue = queue
    }

    deinit {
        print("BYEBYE")
    }

    static let main: DispatchQueue = DispatchQueue(queue: dispatch_get_main_queue())

    func timer(interval interval: NSTimeInterval, handler: Void -> Void) -> DispatchSource {
        let source = DispatchSource(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(source.source, DISPATCH_TIME_NOW, timeIntervalToNSEC(interval), 0)
        source.eventHandler = handler
        source.cancelHandler = {
            [weak source] in
            print(DispatchQueue.timers)
            if let source = source {
                DispatchQueue.timers.remove(source)
            }
        }
        DispatchQueue.timers.insert(source)
        source.resume()
        return source
    }

    static var timers = Set<DispatchSource> ()

}

class DispatchSource {
    let source: dispatch_source_t

    init(source: dispatch_source_t) {
        self.source = source
    }

    deinit {
        print("BYE")
    }

    convenience init(_ type: dispatch_source_type_t, _ handle: UInt, _ mask: UInt, _ queue: dispatch_queue_t) {
        let source = dispatch_source_create(type, handle, mask, queue)
        self.init(source: source)
    }

    var eventHandler: (Void -> Void)? {
        didSet {
            dispatch_source_set_event_handler(source, eventHandler)
        }
    }

    var cancelHandler: (Void -> Void)? {
        didSet {
            dispatch_source_set_cancel_handler(source, cancelHandler)
        }
    }

    func resume() {
        dispatch_resume(source)
    }

}

extension DispatchSource: Equatable {
}

func == (lhs: DispatchSource, rhs: DispatchSource) -> Bool {
    return lhs.source === rhs.source
}


extension DispatchSource: Hashable {
    var hashValue: Int {
        return unsafeBitCast(source, Int.self)
    }
}




func timeIntervalToNSEC(interval: NSTimeInterval) -> Int64 {
    return Int64(interval * NSTimeInterval(NSEC_PER_SEC))
}

func timeIntervalToNSEC(interval: NSTimeInterval) -> UInt64 {
    return UInt64(interval * NSTimeInterval(NSEC_PER_SEC))
}





extension UITableView {

    func scrollToBottom(animated: Bool) {

        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1
        guard numberOfRowsInSection(lastSection) > 0 else {
            return
        }

        let lastRow = max(numberOfRowsInSection(lastSection) - 1, 0)
        scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: lastSection), atScrollPosition: .Bottom, animated: animated)

    }

}