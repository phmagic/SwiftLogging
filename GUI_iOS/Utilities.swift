//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import UIKit

extension UITableView {

    func scrollToBottom(_ animated: Bool) {

        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1
        guard numberOfRows(inSection: lastSection) > 0 else {
            return
        }

        let lastRow = max(numberOfRows(inSection: lastSection) - 1, 0)
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: animated)

    }

}
