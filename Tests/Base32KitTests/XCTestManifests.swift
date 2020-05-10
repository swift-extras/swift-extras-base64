import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(EncodingTests.allTests),
            testCase(DecodingTests.allTests),
            testCase(ValidationTests.allTests),
        ]
    }
#endif
