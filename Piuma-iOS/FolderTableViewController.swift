import UIKit
import PiumaCore

// MARK: Properties

/// Displays a single folder RequestNode.
class FolderTableViewController: UITableViewController {

    /// Folder to display.
    var folder: RequestNode! {
        didSet {
            navigationItem.title = folder.name
        }
    }
}

// MARK: UITableViewController

extension FolderTableViewController {

    /// Returns the number of rows in the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.children?.count ?? 0
    }

    /// Builds a cell to represent a child node.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath)
        let node = folder.children![indexPath.row]
        cell.textLabel!.text = node.name
        cell.accessoryType = node.kind == .folder ? .disclosureIndicator : .none
        return cell
    }
}

// MARK: UIViewController

extension FolderTableViewController {

    /// Prepares the transition to another view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let childFolderTableViewController = segue.destination as! FolderTableViewController
        childFolderTableViewController.folder = folder.children![selectedIndexPath.row]
    }
}

// MARK: Node Creation

extension FolderTableViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        // FIXME: Localization
        let createRequestCommand = UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(createRequest), discoverabilityTitle: "New Request")
        let createFolderCommand = UIKeyCommand(input: "n", modifierFlags: [.command, .shift], action: #selector(createFolder), discoverabilityTitle: "New Folder")
        return [createRequestCommand, createFolderCommand]
    }

    /// Create a new request.
    @IBAction private func createRequest() {
        presentCreateNodeAlert(kind: .request)
    }

    /// Create a new folder.
    @IBAction private func createFolder() {
        presentCreateNodeAlert(kind: .folder)
    }

    /// Presents an alert to create a new node. This alert contains a text field to choose the node name.
    private func presentCreateNodeAlert(kind: RequestNode.Kind) {

        let currentFolder = folder!

        let title: String
        switch kind {
        case .request:
            title = NSLocalizedString("FolderTableViewController.presentCreateNodeAlert.title.request", value: "New Request", comment: "Alert title to create a new request.")
        case .folder:
            title = NSLocalizedString("FolderTableViewController.presentCreateNodeAlert.title.folder", value: "New Folder", comment: "Alert title to create a new folder.")
        }
        let cancelButtonTitle = NSLocalizedString("FolderTableViewController.presentCreateNodeAlert.cancelButtonTitle", value: "Cancel", comment: "Button title to cancel creation of either a request or a folder.")
        let okButtonTitle = NSLocalizedString("FolderTableViewController.presentCreateNodeAlert.okButtonTitle", value: "Create", comment: "Button title to confirm creation of either a request or a folder.")
        func configureTextField(_ textField: UITextField) {
            textField.placeholder = NSLocalizedString("FolderTableViewController.presentCreateNodeAlert.textFieldPlaceholder", value: "Name", comment: "Placeholder to the text field to choose the name of the new request or folder.")
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        func completion(result: UIAlertController.TextInputResult) {
            switch result {
            case .ok(let name):
                currentFolder.addChild(kind: kind, name: name)
            case .cancel:
                break
            }
        }

        present(UIAlertController(title: title, cancelButtonTitle: cancelButtonTitle, okButtonTitle: okButtonTitle, validate: .nonEmpty, textFieldConfiguration: configureTextField, onCompletion: completion), animated: true)
    }
}
