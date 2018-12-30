//
//  Document.swift
//  Piuma-macOS
//
//  Created by Igor Camilo on 22/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import Cocoa
import PiumaCore

class Document: NSDocument {

    private(set) var core = DocumentCore()

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return try core.encode()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        core = try .decode(data: data)
        core.undoManager = undoManager
    }
}

