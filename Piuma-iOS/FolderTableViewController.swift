import UIKit
import PiumaCore

// MARK: Properties

/// Displays a single folder RequestNode.
class FolderTableViewController: UITableViewController {

    /// Folder to display.
    var folder: RequestNode! {
        didSet {
            navigationItem.title = folder.name
            folder.observer = self
        }
    }
}

// MARK: Node Creation

extension FolderTableViewController {

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

// MARK: Node Delete

extension FolderTableViewController {

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            folder.removeChild(at: indexPath.row)
        case .insert, .none:
            break
        }
    }
}

// MARK: RequestNodeObserver

extension FolderTableViewController: RequestNodeObserver {

    func requestNodeDidBeginUpdates(_ requestNode: RequestNode) {
        tableView.beginUpdates()
    }

    func requestNode(_ requestNode: RequestNode, didRemoveChildrenAt indexes: IndexSet) {
        tableView.deleteRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
    }

    func requestNode(_ requestNode: RequestNode, didInsertChildrenAt indexes: IndexSet) {
        tableView.insertRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
    }

    func requestNode(_ requestNode: RequestNode, didUpdateChildrenAt indexes: IndexSet) {
        tableView.reloadRows(at: indexes.map { IndexPath(row: $0, section: 0) }, with: .automatic)
    }

    func requestNode(_ requestNode: RequestNode, didMoveChildFrom oldIndex: Int, newIndex: Int) {
        tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
    }

    func requestNodeDidFinishUpdates(_ requestNode: RequestNode) {
        tableView.endUpdates()
    }
}

// MARK: UITableViewController

extension FolderTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.children?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = folder.children![indexPath.row]
        switch node.kind {
        case .request:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
            cell.textLabel!.text = node.name
            cell.accessoryType = splitViewController!.isCollapsed ? .disclosureIndicator : .none
            return cell
        case .folder:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
            cell.textLabel!.text = node.name
            return cell
        }
    }
}

// MARK: UIViewController

extension FolderTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.isSpringLoaded = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let childFolderTableViewController = segue.destination as! FolderTableViewController
        childFolderTableViewController.folder = folder.children![selectedIndexPath.row]
    }
}

// MARK: UIResponder

extension FolderTableViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        let createRequestCommand = UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(createRequest), discoverabilityTitle: NSLocalizedString("FolderTableViewController.keyCommands.createRequestCommand", value: "New Request", comment: "Command title to create a new request."))
        let createFolderCommand = UIKeyCommand(input: "n", modifierFlags: [.command, .shift], action: #selector(createFolder), discoverabilityTitle: NSLocalizedString("FolderTableViewController.keyCommands.folderRequestCommand", value: "New Folder", comment: "Command title to create a new folder."))
        return [createRequestCommand, createFolderCommand]
    }
}
