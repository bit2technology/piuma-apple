import Foundation

/// A class representing either a request or a folder.
public final class RequestNode: Codable {

    /// A unique identifier of this node.
    public let id: UUID
    /// Either a request or a folder.
    public let kind: Kind
    /// Non-empty name of this node.
    public var name: String
    /// Reference to the parent node.
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
    internal init(kind: Kind, name: String) {
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

    /// Validate subtree integrity and fix whatever it can. Must be called at least once before start using the subtree.
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
            $0.parent = self
            $0.document = document
            try $0.validate()
        }
    }
}

extension RequestNode {

    /// Create a new child and add at the specified index or at the end of the list.
    public func addChild(kind: Kind, name: String, at index: Int? = nil) {
        if children == nil { children = [] }
        addChild(RequestNode(kind: kind, name: name), at: index)
    }

    /// Add a child node at the specified index or at the end of the list.
    private func addChild(_ child: RequestNode, at index: Int?) {
        if children == nil { children = [] }
        document?.undoManager?.beginUndoGrouping()
        let oldParent = child.parent
        let oldIndex = oldParent?.removeChild(child)
        child.parent = self
        child.document = document
        let index = index ?? children!.endIndex
        observer?.requestNodeDidBeginUpdates(self)
        children!.insert(child, at: index)
        observer?.requestNode(self, didInsertChildrenAt: IndexSet(integer: index))
        observer?.requestNodeDidFinishUpdates(self)
        document?.undoManager?.registerUndo(withTarget: self) {
            let child = $0.removeChild(at: index)
            if let parent = oldParent, let index = oldIndex {
                parent.addChild(child, at: index)
            }
        }
        document?.undoManager?.endUndoGrouping()
    }

    /// Remove a child and returns the index where it was.
    private func removeChild(_ child: RequestNode) -> Int? {
        let foundIndex = children!.firstIndex { $0 === child }
        guard let index = foundIndex else { return nil }
        removeChild(at: index)
        return index
    }

    /// Remove a child at a specified index.
    @discardableResult
    public func removeChild(at index: Int) -> RequestNode {
        observer?.requestNodeDidBeginUpdates(self)
        let child = children!.remove(at: index)
        observer?.requestNode(self, didRemoveChildrenAt: IndexSet(integer: index))
        observer?.requestNodeDidFinishUpdates(self)
        document?.undoManager?.registerUndo(withTarget: self) {
            $0.addChild(child, at: index)
        }
        return child
    }
}

/// Observer of node modifications.
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
