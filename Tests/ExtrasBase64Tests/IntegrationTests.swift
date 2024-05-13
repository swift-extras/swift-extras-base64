@testable import ExtrasBase64
import XCTest

class IntegrationTests: XCTestCase {
    func testEncodeAndDecodingĨ() throws {
        var input = "Ĩ"
        let encoded = input.withUTF8 { ptr -> String in
            Base64.encodeString(bytes: ptr)
        }

        let decoded = try Base64.decode(string: encoded)
        let output = String(decoding: decoded, as: Unicode.UTF8.self)

        XCTAssertEqual(input, output)
    }
}
