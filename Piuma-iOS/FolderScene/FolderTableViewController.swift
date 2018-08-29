import UIKit
import PiumaCore

/// Displays a single folder RequestNode.
class FolderTableViewController: UITableViewController {

    /// Folder to display.
    var folder: RequestNode! {
        didSet {
            navigationItem.title = folder.name
            folder.observer = self
        }
    }

    /// Index of a node in process of being renamed.
    private var renamingNodeIndex: Int? {
        didSet { if let oldIndex = oldValue { tableView.reloadRows(at: [IndexPath(row: oldIndex, section: 0)], with: .automatic) } }
    }

    /// Undo button in toolbar.
    @IBOutlet private weak var undoButton: UIBarButtonItem!
    /// Redo button in toolbar.
    @IBOutlet private weak var redoButton: UIBarButtonItem!
}

extension FolderTableViewController {

    /// Create a new request.
    @IBAction private func createRequest() {
        presentCreateNodeFlow(kind: .request)
    }

    /// Create a new folder.
    @IBAction private func createFolder() {
        presentCreateNodeFlow(kind: .folder)
    }

    /// Presents the UI flow to create a new node.
    private func presentCreateNodeFlow(kind: RequestNode.Kind) {
        tableView.beginUpdates()
        renamingNodeIndex = folder.newChild(kind: kind)
        tableView.endUpdates()
        let indexPath = IndexPath(row: renamingNodeIndex!, section:0)
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        (tableView.cellForRow(at: indexPath) as! NodeRenamingTableViewCell).nameField.selectAll(nil)
    }
}

extension FolderTableViewController {

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            folder.deleteChild(at: indexPath.row)
        case .insert, .none:
            break
        }
    }
}

extension FolderTableViewController {

    /// Undo last action.
    @IBAction private func performUndo() {
        undoManager!.undo()
    }

    /// Redo last undone action.
    @IBAction private func performRedo() {
        undoManager!.redo()
    }

    /// Update undo/redo buttons enabled state.
    @objc private func updateUndoRedoButtons() {
        undoButton.isEnabled = undoManager!.canUndo
        redoButton.isEnabled = undoManager!.canRedo
    }
}

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

extension FolderTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.children?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = folder.children![indexPath.row]
        if indexPath.row == renamingNodeIndex {
            return cellForRenamingNode(node, indexPath: indexPath)
        }
        switch node.kind {
        case .request:
            return cellForRequest(node, indexPath: indexPath)
        case .folder:
            return cellForFolder(node, indexPath: indexPath)
        }
    }

    /// Configure cell for renaming a node.
    private func cellForRenamingNode(_ node: RequestNode, indexPath: IndexPath) -> NodeRenamingTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeRenamingCell", for: indexPath) as! NodeRenamingTableViewCell
        cell.nameField.text = node.name
        return cell
    }

    /// Configure cell for a request.
    private func cellForRequest(_ node: RequestNode, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! NodeTableViewCell
        cell.nameLabel.text = node.name
        cell.accessoryType = splitViewController?.isCollapsed == false ? .none : .disclosureIndicator
        return cell
    }

    /// Configure cell for a folder.
    private func cellForFolder(_ node: RequestNode, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! NodeTableViewCell
        cell.nameLabel.text = node.name
        return cell
    }
}

extension FolderTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.isSpringLoaded = true
        updateUndoRedoButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoRedoButtons), name: NSNotification.Name.NSUndoManagerCheckpoint, object: undoManager)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        let childFolderTableViewController = segue.destination as! FolderTableViewController
        childFolderTableViewController.folder = folder.children![selectedIndexPath.row]
    }
}

extension FolderTableViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var undoManager: UndoManager? {
        return folder.document?.undoManager
    }

    override var keyCommands: [UIKeyCommand]? {
        return createNodeKeyCommands + undoRedoKeyCommands
    }

    /// Create request/folder keyboard shortcuts.
    private var createNodeKeyCommands: [UIKeyCommand] {
        let createRequestCommand = UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(createRequest), discoverabilityTitle: NSLocalizedString("FolderTableViewController.createNodeKeyCommands.createRequestCommand", value: "New Request", comment: "Command title to create a new request."))
        let createFolderCommand = UIKeyCommand(input: "n", modifierFlags: [.command, .shift], action: #selector(createFolder), discoverabilityTitle: NSLocalizedString("FolderTableViewController.createNodeKeyCommands.folderRequestCommand", value: "New Folder", comment: "Command title to create a new folder."))
        return [createRequestCommand, createFolderCommand]
    }

    /// Undo/redo keyboard shortcuts if available.
    private var undoRedoKeyCommands: [UIKeyCommand] {
        var keyCommands: [UIKeyCommand] = []
        if undoManager!.canUndo {
            keyCommands.append(UIKeyCommand(input: "z", modifierFlags: [.command], action: #selector(performUndo), discoverabilityTitle: undoManager!.undoMenuItemTitle))
        }
        if undoManager!.canRedo {
            keyCommands.append(UIKeyCommand(input: "z", modifierFlags: [.command, .shift], action: #selector(performRedo), discoverabilityTitle: undoManager!.redoMenuItemTitle))
        }
        return keyCommands
    }
}
