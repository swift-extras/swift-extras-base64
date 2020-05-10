import XCTest
@testable import Base32Kit

final class ValidationTests: XCTestCase {

    static var allTests = [
        // Normal alphabet tests:
        ("testValidPadding", testValidPadding),
        ("testInvalidPadding", testInvalidPadding)
    ]

    func testValidPadding() {
        // given:
        let encodedStrings: [String] = [
            "",
            "MY======",
            "MZXQ====",
            "MZXW6===",
            "MZXW6YQ=",
            "MZXW6YTB",
            "MZXW6YTBOI======"
        ]

        for encodedString in encodedStrings {
            // when:
            let hasInvalidPadding = Base32.invalidPadding(in: encodedString)

            // then:
            XCTAssertFalse(hasInvalidPadding, "Encoded String '\(encodedString)' has no invalid padding.")
        }
    }

    func testInvalidPadding() {
        // given:
        let encodedStrings: [String] = [
            // Invalid "trailing" padding:
            "========",
            "M=======",
            "MZX=====",
            "MZXW6Y==",
            "================",
            "MZXW6YTBM=======",
            "MZXW6YTBMZX=====",
            "MZXW6YTBMZXW6Y==",

            // Invalid padding at random positions:
            "=ZXW6===",
            "=ZXW6YTB",
            "M=XW6YTB",
            "MZ=W6YTB",
            "MZX=6YTB",
            "MZXW=YTB",
            "MZXW6=TB",
            "MZXW6Y=B",
            "M=XW6Y=B",
            "=ZXW6Y=B",
            "=ZXW6YTBOI======",
            "MZXW6Y=BOI======",
            "MZ=W6Y=BOI======",
            "=ZXW6Y=BOI======"
        ]

        for encodedString in encodedStrings {
            // when:
            let hasInvalidPadding = Base32.invalidPadding(in: encodedString)

            // then:
            XCTAssertTrue(hasInvalidPadding, "Encoded String '\(encodedString)' has invalid padding.")
        }
    }
}
