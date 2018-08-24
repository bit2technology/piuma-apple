//
//  DocumentViewController.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 21/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

class DocumentViewController: UISplitViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!

    var document: Document! {
        didSet {
            rootFolderTableViewController.folder = document.core.rootFolder
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rootFolderTableViewController.navigationItem.leftBarButtonItem = closeButton
    }

    private var rootFolderTableViewController: FolderTableViewController {
        let masterNavigationController = viewControllers[0] as! UINavigationController
        return masterNavigationController.viewControllers[0] as! FolderTableViewController
    }

    private func present(error: Error?) {
        // TODO: Proper error presentation
        fatalError("Error in document screen: \(error.debugDescription)")
    }

    @IBAction private func closeAction() {
        close()
    }

    func close(completionHandler: (() -> Void)? = nil) {
        document.close { [weak self] (success) in
            if success {
                self?.presentingViewController!.dismiss(animated: true)
                completionHandler?()
            } else {
                self?.present(error: nil)
            }
        }
    }
}
