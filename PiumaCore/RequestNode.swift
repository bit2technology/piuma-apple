//
//  RequestNode.swift
//  PiumaCore
//
//  Created by Igor Camilo on 20/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public final class RequestNode: Codable {

    public let id: UUID
    public let kind: Kind
    public var name: String
    public private(set) weak var parent: RequestNode?
    internal weak var document: DocumentCore?

    public private(set) var children: [RequestNode]?

    public var url: String?

    internal init(kind: Kind, name: String) {
        id = UUID()
        self.kind = kind
        self.name = name
    }

    public func addChild(kind: Kind, name: String) { // FIXME: Improve
        if children == nil { children = [] }
        children!.append(RequestNode(kind: kind, name: name))
    }

    private enum CodingKeys: String, CodingKey {
        case id, kind, name, children, url
    }

    public enum Kind: String, Codable {
        case request, folder
    }
}

extension RequestNode {

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

    private func validateRequest() throws {
        guard children == nil else {
            throw RequestNodeError.requestWithChildren(self)
        }
    }

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

public enum RequestNodeError: Error {
    case emptyName(RequestNode)
    case requestWithChildren(RequestNode)
    case folderWithURL(RequestNode)
    case cantAccessUndo(RequestNode)
}
