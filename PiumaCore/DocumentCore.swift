//
//  DocumentCore.swift
//  PiumaCore
//
//  Created by Igor Camilo on 20/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Foundation

public final class DocumentCore: Codable {

    public let rootFolder: RequestNode
    public var undoManager: UndoManager?

    public init() {
        rootFolder = RequestNode(kind: .folder, name: NSLocalizedString("DocumentCore.rootFolder.defaultName", value: "Requests", comment: "Default name for the root folder on a just created document. The document is a collection of network requests, usually [REST](https://en.wikipedia.org/wiki/Representational_state_transfer). **Name can't contain characters / or \\ (slash or backslash)!**"))
    }

    internal func validate() throws {
        rootFolder.document = self
        try rootFolder.validate()
    }

    public static func decode(data: Data) throws -> DocumentCore {
        let document = try JSONDecoder().decode(DocumentCore.self, from: data)
        try document.validate()
        return document
    }

    public func encode() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    private enum CodingKeys: String, CodingKey {
        case rootFolder
    }
}
