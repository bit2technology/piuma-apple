//
//  AppDelegate.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 22/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard inputURL.isFileURL else { return false }
        let documentBrowserViewController = window!.rootViewController as! DocumentBrowserViewController
        documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            if let error = error {
                documentBrowserViewController.present(error: error)
                return
            }
            documentBrowserViewController.securelyPresent(documentAt: revealedDocumentURL!)
        }
        return true
    }
}
