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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        log.addDestination(MemoryDestination(identifier: "memory"))

//        DispatchQueue.main.timer(interval: 1) {
////            log.debug(KeyValue(key: "Hello", value: CFAbsoluteTimeGetCurrent()))
//        }

        return true
    }

}

