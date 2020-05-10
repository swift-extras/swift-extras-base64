import XCTest
@testable import Base32Kit

final class DecodingTests: XCTestCase {

    static var allTests = [
        // Normal alphabet tests:
        ("testRFC4648TestVectors", testRFC4648TestVectors),
        ("testLowerCaseRFC4648TestVectors", testLowerCaseRFC4648TestVectors),
        ("testInvalidLength", testInvalidLength),
        ("testInvalidAsciiCharacters", testInvalidAsciiCharacters),
        ("testEmoji", testEmoji),
        ("testLineBreaks", testLineBreaks),
        ("testMisplacedPaddingCharacter", testMisplacedPaddingCharacter),
        ("testNulCharacter", testNulCharacter),
        ("testCaseSensitivity", testCaseSensitivity),

        // Hex alphabet tests:
        ("testHexRFC4648TestVectors", testHexRFC4648TestVectors),
        ("testHexLowerCaseRFC4648TestVectors", testHexLowerCaseRFC4648TestVectors),
        ("testHexInvalidLength", testHexInvalidLength),
        ("testHexInvalidAsciiCharacters", testHexInvalidAsciiCharacters),
        ("testHexEmoji", testHexEmoji),
        ("testHexLineBreaks", testHexLineBreaks),
        ("testHexMisplacedPaddingCharacter", testHexMisplacedPaddingCharacter),
        ("testHexNulCharacter", testHexNulCharacter),
        ("testHexCaseSensitivity", testHexCaseSensitivity)
    ]

    private let invalidAsciiCharacters: Set<UInt8> = {
        // Create a Set of all ASCII characters, including the following sets of characters:
        //
        // 1. ASCII control characters (0 - 31)
        // 2. ASCII printable characters (32 - 127)
        // 3. ASCII extended character set (128 - 255)
        var asciiCharacters = Set<UInt8>(0...255)

        // Remove all valid characters as defined by the Base 32 alphabet (all upper case) from the list:
        asciiCharacters.subtract(Set(Alphabet.base32))

        // Remove the lowercase variants of the valid Base 32 alphabet from the list. The lowercase characters have a
        // "distance" of 32 from their uppercase variants.
        //
        // For example: The uppercase "A" has the decimal ASCII code of 65. The lowercase "a" has a decimal ASCII code
        // of 97. The "distance" between them is 32.
        asciiCharacters.subtract(Set(Alphabet.base32.map { $0 + 32 }))

        // Remove the padding character ("=") from the list, because it is allowed:
        asciiCharacters.remove(Alphabet.encodePaddingCharacter)

        // Remove the "NUL" control character. It can not be part of a String and therefore is a "non character". There
        // is a separate test to specfically test for the NUL character.
        asciiCharacters.remove(0)

        return asciiCharacters
    }()

    private let invalidAsciiCharactersHex: Set<UInt8> = {
        // Create a Set of all ASCII characters, including the following sets of characters:
        //
        // 1. ASCII control characters (0 - 31)
        // 2. ASCII printable characters (32 - 127)
        // 3. ASCII extended character set (128 - 255)
        var asciiCharacters = Set<UInt8>(0...255)

        // Remove all valid characters as defined by the Base 32 alphabet (all upper case) from the list:
        asciiCharacters.subtract(Set(Alphabet.base32hex))

        // Remove the lowercase variants of the valid Base 32 alphabet from the list. The lowercase characters have a
        // "distance" of 32 from their uppercase variants.
        //
        // For example: The uppercase "A" has the decimal ASCII code of 65. The lowercase "a" has a decimal ASCII code
        // of 97. The "distance" between them is 32.
        asciiCharacters.subtract(Set(Alphabet.base32hex.map { $0 + 32 }))

        // Remove the padding character ("=") from the list, because it is allowed:
        asciiCharacters.remove(Alphabet.encodePaddingCharacter)

        // Remove the "NUL" control character. It can not be part of a String and therefore is a "non character". There
        // is a separate test to specfically test for the NUL character.
        asciiCharacters.remove(0)

        return asciiCharacters
    }()

    func testRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "MY======": "f",
            "MZXQ====": "fo",
            "MZXW6===": "foo",
            "MZXW6YQ=": "foob",
            "MZXW6YTB": "fooba",
            "MZXW6YTBOI======": "foobar"
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(
                decoded,
                expected,
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func testLowerCaseRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "my======": "f",
            "mzxq====": "fo",
            "mzxw6===": "foo",
            "mzxw6yq=": "foob",
            "mzxw6ytb": "fooba",
            "mzxw6ytboi======": "foobar"
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(
                decoded,
                expected,
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func testInvalidLength() {
        let testData = generateRandomInvalidLengthStrings(count: 100, alphabet: Alphabet.base32)

        for encoded in testData {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidLength
            )
        }
    }

    func testInvalidAsciiCharacters() {
        for character in invalidAsciiCharacters {
            let encoded = String(format: "%c=======", character)

            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.illegalCharactersFound([Character(UnicodeScalar(character))])
            )
        }
    }

    func testIllegalCharactersErrorContentUniqness() {
        // given:
        let encoded = "11======" // "1" is a illegal character

        assert(
            // when:
            try Base32.decode(string: encoded),

            // then:
            throws: Base32.DecodingError.illegalCharactersFound(Set<Character>(arrayLiteral: "1"))
        )
    }

    func testIllegalCharactersErrorContent() {
        // given:
        let encoded = "10======"

        assert(
            // when:
            try Base32.decode(string: encoded),

            // then:
            throws: Base32.DecodingError.illegalCharactersFound(Set<Character>(arrayLiteral: "0", "1"))
        )
    }

    func testEmoji() {
        let emojiRanges = [
            0x1F600...0x1F636,
            0x1F645...0x1F64F,
            0x1F910...0x1F91F,
            0x1F30D...0x1F52D
        ]

        for subRange in emojiRanges {
            for emojiScalar in subRange {
                guard let emoji = UnicodeScalar(emojiScalar) else {
                    continue
                }

                let encoded = String(emoji) + "======="
                assert(
                    try Base32.decode(string: encoded),
                    throws: Base32.DecodingError.illegalCharactersFound([Character(emoji)])
                )
            }
        }
    }

    func testLineBreaks() throws {
        let testStrings: [String: String] = [
            // New lines at the end of the string:
            "a======\n": "\n",
            "a======\r\n": "\r\n",

            // New lines in the middle of the string:
            "a===\n===": "\n",
            "a===\r\n===": "\r\n",

            // New lines at the beginning of the string:
            "\na======": "\n",
            "\r\na======": "\r\n"
        ]

        for (encoded, invalidCharacter) in testStrings {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.illegalCharactersFound([Character(invalidCharacter)])
            )
        }
    }

    func testMisplacedPaddingCharacter() {
        let testStrings: [String] = [
            // Only padding (not allowed):
            "========",

            // Padding at the beginning of a "valid" Base 32 encoded String:
            "=ZXW6===",

            // Move padding through a valid String:
            "=ZXW6YTB",
            "M=XW6YTB",
            "MZ=W6YTB",
            "MZX=6YTB",
            "MZXW=YTB",
            "MZXW6=TB",
            "MZXW6Y=B",

            // Technically correct padding, but at positions that are not valid:
            "MZXW6Y==",
            "MZX=====",

            // Padding at different invalid positions:
            "M=XW6Y=B",
            "=ZXW6Y=B",

            // Invalid padding in a Base 32 encoded String that is longer than a single "block":
            "================",
            "=ZXW6YTBOI======",
            "MZXW6Y=BOI======",
            "MZ=W6Y=BOI======",
            "=ZXW6Y=BOI======"
        ]

        for encoded in testStrings {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidPaddingCharacters
            )
        }
    }

    /// Tests if decoding breaks if the string contains a NUL character.
    ///
    /// As stated in RFC4648, section 12:
    ///
    /// "A decoder should not break on invalid input including, e.g., embedded NUL characters (ASCII 0)."
    ///
    /// - SeeAlso: https://tools.ietf.org/html/rfc4648#section-12
    func testNulCharacter() {
        let bytes: [UInt8] = [
            77, // M
            90, // Z
             0, // NUL <-- This should not break the decoder.
            81, // Q
            61, // =
            61, // =
            61, // =
            61  // =
        ]

        let encoded = String(decoding: bytes, as: Unicode.UTF8.self)

        assert(
            try Base32.decode(string: encoded),
            throws: Base32.DecodingError.illegalCharactersFound([Character(UnicodeScalar(0))])
        )
    }

    func testCaseSensitivity() throws {
        let testData: [String: String] = [
            "": "",
            "MY======": "f",
            "MzXq====": "fo",
            "MZxw6===": "foo",
            "mZXW6yQ=": "foob",
            "MZXW6Ytb": "fooba",
            "mzXw6YTBoI======": "foobar"
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(
                decoded,
                expected,
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func testHexRFC4648TestVectors() throws {
        let stringsToDecode: [String: String] = [
            "": "",
            "CO======": "f",
            "CPNG====": "fo",
            "CPNMU===": "foo",
            "CPNMUOG=": "foob",
            "CPNMUOJ1": "fooba",
            "CPNMUOJ1E8======": "foobar"
        ]

        for (stringToDecode, expected) in stringsToDecode {
            let encoded = try Base32.decodeHex(string: stringToDecode)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(stringToDecode)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testHexLowerCaseRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "co======": "f",
            "cpng====": "fo",
            "cpnmu===": "foo",
            "cpnmuog=": "foob",
            "cpnmuoj1": "fooba",
            "cpnmuoj1e8======": "foobar"
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decodeHex(string: input)
            XCTAssertEqual(
                decoded,
                expected,
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func testHexInvalidLength() {
        let testData = generateRandomInvalidLengthStrings(count: 100, alphabet: Alphabet.base32hex)

        for encoded in testData {
            assert(
                try Base32.decodeHex(string: encoded),
                throws: Base32.DecodingError.invalidLength
            )
        }
    }

    func testHexInvalidAsciiCharacters() {
        for character in invalidAsciiCharactersHex {
            let encoded = String(format: "%c=======", character)

            assert(
                try Base32.decodeHex(string: encoded),
                throws: Base32.DecodingError.illegalCharactersFound([Character(UnicodeScalar(character))])
            )
        }
    }

    /// Test to verify that the "illegalCharacters" Set that is part of the
    /// `Base32.DecodingError.illegalCharactersFound` error only contains one "instance" of the offending character.
    func testHexIllegalCharactersErrorContentUniqness() {
        // given:
        let encoded = "ZZ======" // "1" is a illegal character

        assert(
            // when:
            try Base32.decodeHex(string: encoded),

            // then:
            throws: Base32.DecodingError.illegalCharactersFound(Set<Character>(arrayLiteral: "Z"))
        )
    }

    func testHexIllegalCharactersErrorContent() {
        // given:
        let encoded = "YZ======"

        assert(
            // when:
            try Base32.decodeHex(string: encoded),

            // then:
            throws: Base32.DecodingError.illegalCharactersFound(Set<Character>(arrayLiteral: "Z", "Y"))
        )
    }

    func testHexEmoji() {
        let emojiRanges = [
            0x1F600...0x1F636,
            0x1F645...0x1F64F,
            0x1F910...0x1F91F,
            0x1F30D...0x1F52D
        ]

        for subRange in emojiRanges {
            for emojiScalar in subRange {
                guard let emoji = UnicodeScalar(emojiScalar) else {
                    continue
                }

                let encoded = String(emoji) + "======="
                assert(
                    try Base32.decodeHex(string: encoded),
                    throws: Base32.DecodingError.illegalCharactersFound([Character(emoji)])
                )
            }
        }
    }

    func testHexLineBreaks() throws {
        let testStrings: [String: String] = [
            // New lines at the end of the string:
            "a======\n": "\n",
            "a======\r\n": "\r\n",

            // New lines in the middle of the string:
            "a===\n===": "\n",
            "a===\r\n===": "\r\n",

            // New lines at the beginning of the string:
            "\na======": "\n",
            "\r\na======": "\r\n"
        ]

        for (encoded, invalidCharacter) in testStrings {
            assert(
                try Base32.decodeHex(string: encoded),
                throws: Base32.DecodingError.illegalCharactersFound([Character(invalidCharacter)])
            )
        }
    }

    func testHexMisplacedPaddingCharacter() {
        let testStrings: [String] = [
            // Only padding (not allowed):
            "========",

            // Padding at the beginning of a "valid" Base 32 encoded String:
            "=PNMU===",

            // Move padding through a valid String:
            "=PNMUOJ1",
            "C=NMUOJ1",
            "CP=MUOJ1",
            "CPN=UOJ1",
            "CPNM=OJ1",
            "CPNMU=J1",
            "CPNMUO=1",

            // Padding at different invalid positions:
            "C=NMUO=1",
            "=PNMUO=1",

            // Invalid padding in a Base 32 encoded String that is longer than a single "block":
            "================",
            "=PNMUOJ1E8======",
            "CPNMUO=1E8======",
            "CP=MUO=1E8======",
            "=PNMUO=1E8======"
        ]

        for encoded in testStrings {
            assert(
                try Base32.decodeHex(string: encoded),
                throws: Base32.DecodingError.invalidPaddingCharacters
            )
        }
    }

    func testHexNulCharacter() {
        let bytes: [UInt8] = [
            67, // C
            80, // P
             0, // NUL <-- This should not break the decoder.
            71, // G
            61, // =
            61, // =
            61, // =
            61  // =
        ]

        let encoded = String(decoding: bytes, as: Unicode.UTF8.self)

        assert(
            try Base32.decodeHex(string: encoded),
            throws: Base32.DecodingError.illegalCharactersFound([Character(UnicodeScalar(0))])
        )
    }

    func testHexCaseSensitivity() throws {
        let testData: [String: String] = [
            "": "",
            "CO======": "f",
            "CpNg====": "fo",
            "CPnmU===": "foo",
            "cPNMUoG=": "foob",
            "CPNMUOj1": "fooba",
            "cpNmUOJ1e8======": "foobar"
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decodeHex(string: input)
            XCTAssertEqual(
                decoded,
                expected,
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    private func generateRandomInvalidLengthStrings(count: Int, alphabet: [UInt8]) -> [String] {
        var result = [String]()

        while result.count != count {
            let length = Int.random(in: 1...1000)

            if length % 8 == 0 {
                continue
            }

            let bytes = (0..<length).map {_ in alphabet.randomElement()!}
            result.append(String(decoding: bytes, as: Unicode.UTF8.self))
        }

        return result
    }
}

extension XCTestCase {
    func assert<T, E: Error & Equatable>(
        _ expression: @autoclosure () throws -> T,
        throws error: E,
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        var thrownError: Error?

        XCTAssertThrowsError(try expression(),
                             file: file, line: line) {
            thrownError = $0
        }

        XCTAssertTrue(
            thrownError is E,
            "Unexpected error type: \(type(of: thrownError))",
            file: file, line: line
        )

        XCTAssertEqual(
            thrownError as? E, error,
            file: file, line: line
        )
    }
}
