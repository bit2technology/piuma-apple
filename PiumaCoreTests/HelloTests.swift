//
//  HelloTests.swift
//  PiumaCoreTests
//
//  Created by Igor Camilo on 22/08/18.
//  Copyright © 2018 Bit2 Technology. All rights reserved.
//

import XCTest
@testable import PiumaCore

class HelloTests: XCTestCase {
    func testHello() {
        XCTAssertEqual(Hello.test, "Hello from PiumaCore!")
    }
}
