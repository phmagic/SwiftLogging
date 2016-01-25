//
//  DataViewController.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import UIKit

class DataViewController: UITableViewController {

    var keys: [String] = []
    var rowsByKey: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        for datum in dataDestination!.data.values {
            updateDatum(datum)
        }
        self.tableView.reloadData()

        dataDestination?.addListener(self) {
            datum in
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in

                self?.updateDatum(datum)
                self?.tableView.reloadData()
            }
        }
    }

    func updateDatum(datum: DataDestination.Datum) {
        var row: Int! = rowsByKey[datum.key]
        if row == nil {
            row = keys.count
            keys.append(datum.key)
            rowsByKey[datum.key] = row
        }
    }

    var dataDestination: DataDestination? {
        return log.destinationForKey("data") as? DataDestination
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let key = keys[indexPath.row]
        let datum = dataDestination!.data[key]!

        let cell = tableView.dequeueReusableCellWithIdentifier("DATUM_CELL", forIndexPath: indexPath)

        cell.textLabel?.text = key
        cell.detailTextLabel?.text = String(datum.lastValue)

        return cell
    }
}