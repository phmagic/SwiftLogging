//
//  ViewController.swift
//  GUI
//
//  Created by Jonathan Wight on 5/15/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Cocoa

import SwiftLogging

class ViewController: NSViewController {
    dynamic var subject: String?

    @IBAction func log(_ sender: AnyObject) {
        if subject != nil {
            SwiftLogging.log.debug(subject as Any)
            subject = nil
        }
    }

}

