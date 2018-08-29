import Foundation

/// A class representing a node in the request tree.
public final class RequestNode: Codable {

    /// An unique identifier of this node.
    public let id: UUID
    /// Kind of this node.
    public let kind: Kind
    /// Non-empty name of this node.
    public var name: String
    /// Reference to the parent node, if any.
    public private(set) weak var parent: RequestNode?
    /// Reference to the document, if any.
    public internal(set) weak var document: DocumentCore?
    /// Observer of changes in this node.
    public weak var observer: RequestNodeObserver?

    /// Children nodes. Only available to folders.
    public private(set) var children: [RequestNode]?

    /// URL to request. Only available to requests.
    public var url: String?

    /// Designated intializer. If no name is provided, it is used a default name for a node that was just created.
    internal init(kind: Kind, name: String? = nil) {
        id = UUID()
        self.kind = kind
        self.name = name ?? RequestNode.defaultName(for: kind)
    }

    private static func defaultName(for kind: Kind) -> String {
        switch kind {
        case .request:
            return NSLocalizedString("RequestNode.defaultName.request", value: "New Request", comment: "Name of a request that was just created.")
        case .folder:
            return NSLocalizedString("RequestNode.defaultName.folder", value: "New Folder", comment: "Name of a folder that was just created.")
        }
    }

    /// Codable keys.
    private enum CodingKeys: String, CodingKey {
        case id, kind, name, children, url
    }

    /// Either a request or a folder.
    public enum Kind: String, Codable {
        case request, folder
    }
}

extension RequestNode {

    /// Validate subtree integrity and fix whatever it can. Must be called at least once before start using the nodes in the subtree.
    internal func validate() throws {
        guard !name.isEmpty else {
            throw RequestNodeError.emptyName(self)
        }
        switch kind {
        case .request:
            try validateRequest()
        case .folder:
            try validateFolder()
        }

    }

    /// Validation specific to requests.
    private func validateRequest() throws {
        guard children == nil else {
            throw RequestNodeError.requestWithChildren(self)
        }
    }

    /// Validation specific to folders.
    private func validateFolder() throws {
        guard url == nil else {
            throw RequestNodeError.folderWithURL(self)
        }
        try children?.forEach {
            $0.inheritProperties(from: self)
            try $0.validate()
        }
    }

    /// Set parent node and inherit its properties.
    private func inheritProperties(from parent: RequestNode) {
        self.parent = parent
        document = parent.document
    }

    /// Unset properties set in `inheritProperties(from:)`.
    private func unsetInheritedProperties() {
        parent = nil
        document = nil
    }
}

/// Observer of node modifications and events.
public protocol RequestNodeObserver: class {
    func requestNodeDidBeginUpdates(_ requestNode: RequestNode)
    func requestNode(_ requestNode: RequestNode, didRemoveChildrenAt indexes: IndexSet)
    func requestNode(_ requestNode: RequestNode, didInsertChildrenAt indexes: IndexSet)
    func requestNode(_ requestNode: RequestNode, didUpdateChildrenAt indexes: IndexSet)
    func requestNode(_ requestNode: RequestNode, didMoveChildFrom oldIndex: Int, newIndex: Int)
    func requestNodeDidFinishUpdates(_ requestNode: RequestNode)
}

public extension RequestNodeObserver {
    func requestNodeDidBeginUpdates(_ requestNode: RequestNode) {}
    func requestNode(_ requestNode: RequestNode, didRemoveChildrenAt indexes: IndexSet) {}
    func requestNode(_ requestNode: RequestNode, didInsertChildrenAt indexes: IndexSet) {}
    func requestNode(_ requestNode: RequestNode, didUpdateChildrenAt indexes: IndexSet) {}
    func requestNode(_ requestNode: RequestNode, didMoveChildFrom oldIndex: Int, newIndex: Int) {}
    func requestNodeDidFinishUpdates(_ requestNode: RequestNode) {}
}

/// Possible errors.
public enum RequestNodeError: Error {
    case emptyName(RequestNode)
    case requestWithChildren(RequestNode)
    case folderWithURL(RequestNode)
    case cantAccessUndo(RequestNode)
}

// FIXME: - Needs Improvement

extension RequestNode {

    @discardableResult public func newChild(kind: Kind) -> Int {
        if children == nil { children = [] }
        let child = RequestNode(kind: kind)
        let index = children!.endIndex
        insertChild(child, at: index)
        let actionName: String
        switch child.kind {
        case .request:
            actionName = NSLocalizedString("RequestNode.newChild.actionName.request", value: "New Request", comment: "Name of the action of creating and adding a new request to a folder. Used for undo/redo.")
        case .folder:
            actionName = NSLocalizedString("RequestNode.newChild.actionName.folder", value: "New Folder", comment: "Name of the action of creating and adding a new folder to a folder. Used for undo/redo.")
        }
        document?.undoManager?.setActionName(actionName)
        return index
    }

    private func insertChild(_ child: RequestNode, at index: Int) {
        child.inheritProperties(from: self)
        children!.insert(child, at: index)
        observer?.requestNode(self, didInsertChildrenAt: IndexSet(integer: index))
        document?.undoManager?.registerUndo(withTarget: self) { $0.removeChild(at: index) }
    }

    public func deleteChild(at index: Int) {
        let child = removeChild(at: index)
        let actionName: String
        switch child.kind {
        case .request:
            actionName = NSLocalizedString("RequestNode.deleteChild.actionName.request", value: "Delete Request", comment: "Name of the action of removing a request from a folder. Used for undo/redo.")
        case .folder:
            actionName = NSLocalizedString("RequestNode.deleteChild.actionName.folder", value: "Delete Folder", comment: "Name of the action of removing a folder from a folder. Used for undo/redo.")
        }
        document?.undoManager?.setActionName(actionName)
    }

    @discardableResult private func removeChild(at index: Int) -> RequestNode {
        let child = children!.remove(at: index)
        child.unsetInheritedProperties()
        observer?.requestNode(self, didRemoveChildrenAt: IndexSet(integer: index))
        document?.undoManager?.registerUndo(withTarget: self) { $0.insertChild(child, at: index) }
        return child
    }

//    public func moveChildren(_ newChildren: [RequestNode], to index: Int?) {
//        if children == nil { children = [] }
//        let index = index ?? children!.endIndex
//        let newChildrenByParentId = Dictionary(grouping: newChildren) { $0.parent!.id }
//        for (_, children) in newChildrenByParentId {
//
//        }
//    }
}
