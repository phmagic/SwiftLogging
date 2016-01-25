//
//  MemoryLogViewController.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import UIKit

import SwiftLogging

class MemoryLogViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        reload()

        memoryDestination?.addListener(self) {
            _ in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                self?.update()
                self?.tableView.scrollToBottom(true)
            }
        }
    }

    func reload() {
        events = memoryDestination!.events
        tableView.reloadData()
        lastCount = events.count
    }

    func update() {
        events = memoryDestination!.events
        tableView.beginUpdates()
        let indexPaths = (lastCount..<events.count).map {
            return NSIndexPath(forRow: $0, inSection: 0)
        }
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        tableView.endUpdates()
        lastCount = events.count
    }

    var memoryDestination: MemoryDestination? {
        return log.destinationForKey("memory") as? MemoryDestination
    }

    var lastCount = 0
    var events: [Event] = []

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EVENT_CELL", forIndexPath: indexPath)

        let event = events[indexPath.row]
        cell.textLabel?.text = String(event.subject ?? "")
        cell.detailTextLabel?.text = terseFormatter(event)

        return cell
    }

}

