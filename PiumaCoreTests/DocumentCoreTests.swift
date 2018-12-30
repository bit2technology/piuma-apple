import XCTest
@testable import PiumaCore

class DocumentCoreTests: XCTestCase {

    func testCreation() {
        let documentCore = DocumentCore()
        XCTAssertTrue(documentCore.requests.isEmpty)
        XCTAssertNil(documentCore.undoManager)
    }
}
