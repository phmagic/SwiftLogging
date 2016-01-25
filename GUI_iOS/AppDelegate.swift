//
//  AppDelegate.swift
//  GUI_iOS
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import UIKit

import SwiftLogging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        log.addDestination("memory", destination: MemoryDestination())
        log.addDestination("data", destination: DataDestination())

        DispatchQueue.main.timer(interval: 1) {
            log.debug(KeyValue(key: "Hello", value: CFAbsoluteTimeGetCurrent()))
        }

        return true
    }

}

