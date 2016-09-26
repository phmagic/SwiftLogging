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
            DispatchQueue.main.async {
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
            return IndexPath(row: $0, section: 0)
        }
        tableView.insertRows(at: indexPaths, with: .none)
        tableView.endUpdates()
        lastCount = events.count
    }

    var memoryDestination: MemoryDestination? {
        return log.destinationForKey("memory") as? MemoryDestination
    }

    var lastCount = 0
    var events: [Event] = []

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EVENT_CELL", for: indexPath)

        let event = events[indexPath.row]
        cell.textLabel?.text = String(describing: event.subject)
        cell.detailTextLabel?.text = terseFormatter(event)

        return cell
    }

}

