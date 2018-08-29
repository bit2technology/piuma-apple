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

    /// Designated intializer.
    public init(kind: Kind, name: String) {
        id = UUID()
        self.kind = kind
        self.name = name
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

    public func insertChild(_ child: RequestNode, at index: Int? = nil) {
        insertChildWithoutActionName(child, at: index)
        let actionName: String
        switch child.kind {
        case .request:
            actionName = NSLocalizedString("RequestNode.addChild.actionName.request", value: "Create Request", comment: "Name of the action of creating and adding a new request to a folder. Used for undo/redo.")
        case .folder:
            actionName = NSLocalizedString("RequestNode.addChild.actionName.folder", value: "Create Folder", comment: "Name of the action of creating and adding a new folder to a folder. Used for undo/redo.")
        }
        document?.undoManager?.setActionName(actionName)
    }

    private func insertChildWithoutActionName(_ child: RequestNode, at index: Int?) {
        if children == nil { children = [] }
        let index = index ?? children!.endIndex
        child.inheritProperties(from: self)
        children!.insert(child, at: index)
        observer?.requestNode(self, didInsertChildrenAt: IndexSet(integer: index))
        document?.undoManager?.registerUndo(withTarget: self) { $0.removeChildWithoutActionName(at: index) }
    }

    public func removeChild(at index: Int) {
        let child = removeChildWithoutActionName(at: index)
        let actionName: String
        switch child.kind {
        case .request:
            actionName = NSLocalizedString("RequestNode.removeChild.actionName.request", value: "Delete Request", comment: "Name of the action of removing a request from a folder. Used for undo/redo.")
        case .folder:
            actionName = NSLocalizedString("RequestNode.removeChild.actionName.folder", value: "Delete Folder", comment: "Name of the action of removing a folder from a folder. Used for undo/redo.")
        }
        document?.undoManager?.setActionName(actionName)
    }

    @discardableResult private func removeChildWithoutActionName(at index: Int) -> RequestNode {
        let child = children!.remove(at: index)
        child.unsetInheritedProperties()
        observer?.requestNode(self, didRemoveChildrenAt: IndexSet(integer: index))
        document?.undoManager?.registerUndo(withTarget: self) { $0.insertChildWithoutActionName(child, at: index) }
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
