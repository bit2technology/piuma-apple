//
//  AppDelegate.swift
//  Piuma-macOS
//
//  Created by Igor Camilo on 22/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Cocoa
import PiumaCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print(Hello.test)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

