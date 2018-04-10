import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(D4LocalAuthTests.allTests),
    ]
}
#endif