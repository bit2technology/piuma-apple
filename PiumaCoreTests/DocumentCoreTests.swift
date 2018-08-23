//
//  DocumentCoreTests.swift
//  PiumaCoreTests
//
//  Created by Igor Camilo on 20/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import PiumaCore

class DocumentCoreTests: XCTestCase {

    func testCreateRoot() {
        let core = DocumentCore()
        try! core.validate()
    }
}
