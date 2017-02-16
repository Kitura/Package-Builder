import XCTest
@testable import library_dev_snapshot

class library_dev_snapshotTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(library_dev_snapshot().text, "Hello, World!")
    }


    static var allTests : [(String, (library_dev_snapshotTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
