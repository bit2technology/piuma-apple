//
//  DocumentViewController.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 21/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

class DocumentViewController: UISplitViewController {

    var document: Document! {
        didSet {
            // FIXME: Test
            let masterNavigationController = viewControllers.first! as! UINavigationController
            let viewController = masterNavigationController.viewControllers.first!
            viewController.navigationItem.title = document.localizedName
            viewController.navigationItem.leftBarButtonItem = closeBarButtonItem()
        }
    }

    private func present(error: Error?) {
        // TODO: Proper error presentation
        fatalError("Error in document screen: \(error.debugDescription)")
    }

    private func closeBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))
    }

    @objc private func closeAction() {
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
