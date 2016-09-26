//
//  MemoryLogViewController.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 7/20/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Cocoa

import SwiftLogging
import SwiftUtilities

class MemoryLogViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let memoryDestination = MemoryDestination(identifier: "memory")
        log.addDestination(memoryDestination)

        memoryDestination.addListener(self) {
            _ in
            DispatchQueue.main.async {
                [weak self] in
                self?.update()
            }
        }
        reload()
    }

    func reload() {
        events = memoryDestination.events.map(EventBox.init)
        lastCount = events.count
    }

    func update() {
        events = memoryDestination.events.map(EventBox.init)
        lastCount = events.count
    }

    var memoryDestination: MemoryDestination {
        return log.destinationForKey("memory") as! MemoryDestination
    }

    var lastCount = 0
    dynamic var events: [EventBox] = []


}

class EventBox: NSObject {
    let event: Event
    init(event: Event) {
        self.event = event
    }

    var subject: String {

        if case .formatted(let subject) = self.event.subject {
            return String(subject)
        }
        else {
            return String("< UNFORMATTED >")
        }

    }

}
