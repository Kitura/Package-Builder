import XCTest
@testable import library

class LibraryTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(library().text, "Hello, World!")
    }

    static var allTests: [(String, (libraryTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample)
        ]
    }
}
