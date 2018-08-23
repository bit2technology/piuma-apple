//
//  DocumentBrowserViewController.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 20/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    weak var presentedDocumentViewController: DocumentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
    }

    func present(error: Error?) {
        // TODO: Proper error presentation
        fatalError("Error in document browser: \(error.debugDescription)")
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        do {
            try importHandler(Document.templateURL(), .copy)
        } catch {
            importHandler(nil, .none)
            present(error: error)
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        present(documentAt: documentURLs.first!)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        present(documentAt: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        present(error: error)
    }

    func securelyPresent(documentAt url: URL) {
        if let documentViewController = presentedDocumentViewController {
            documentViewController.close { [weak self] in
                self?.present(documentAt: url)
            }
        } else {
            present(documentAt: url)
        }
    }

    private func present(documentAt url: URL) {
        let document = Document(fileURL: url)
        document.open { [weak self] (success) in
            if success {
                self?.performSegue(withIdentifier: "PresentDocument", sender: document)
            } else {
                self?.present(error: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let documentViewController = segue.destination as! DocumentViewController
        documentViewController.document = sender as? Document
        presentedDocumentViewController = documentViewController
    }
}
