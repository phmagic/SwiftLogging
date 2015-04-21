//
//  AppDelegate.swift
//  GUI
//
//  Created by Jonathan Wight on 5/15/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Cocoa

import SwiftLogging

public var logger:Logger! = Logger()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        logger.debug("My password is \"123456\"", tags:Tags(["sensitive"]))

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

