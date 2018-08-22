//
//  AppDelegate.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 22/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit
import PiumaCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(Hello.test)
        return true
    }
}
