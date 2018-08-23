//
//  Document.swift
//  Piuma-iOS
//
//  Created by Igor Camilo on 20/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import UIKit
import PiumaCore

class Document: UIDocument {

    private(set) var core: DocumentCore!
    private(set) var lastError: Error?

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        core = try .decode(data: contents as! Data)
        core.undoManager = undoManager
    }

    override func contents(forType typeName: String) throws -> Any {
        return try core.encode()
    }

    class func templateURL() throws -> URL {
        let defaultCore = DocumentCore()
        let templateURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(defaultCore.rootFolder.name).piuma")
        try defaultCore.encode().write(to: templateURL)
        return templateURL
    }

    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        lastError = error
    }
}
