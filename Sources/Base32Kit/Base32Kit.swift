/// The `Base32` struct contains methods to encode and decode data using the Base 32 encoding as defined
/// by [RFC 4648](https://tools.ietf.org/html/rfc4648).
///
/// The API supports both alphabets defined in the specification for encoding and decoding data:
///
/// 1. The Base 32 Alphabet (see [RFC 4648 Section 6](https://tools.ietf.org/html/rfc4648#section-6))
/// 2. The "Extended Hex" Base 32 Alphabet (see [RFC 4648 Section 7](https://tools.ietf.org/html/rfc4648#section-7))
///
/// The API only supports the encoding and decoding of strings and no other data types. All the inputs are validated
/// and the API will throw exceptions instead of ignoring illegal input.
///
/// All methods are `static` so no instance of the `Base32` struct needs to be created.
///
/// **Examples:**
///
/// ```
/// let encoded = Base32.encode(string: "foobar")
/// print(encoded) // prints "MZXW6YTBOI======"
///
/// if let decoded = try? Base32.decode(string: encoded) {
///     print(decoded) // prints "foobar"
/// }
/// ```
///
/// - Note: Encoding and decoding methods are not optimized and might perform badly. Use another Swift package if
///         performance is a primary concern.
/// - Warning: This API is still under development. APIs are subject to change and error. Do not use in production.
public struct Base32 {
    /// Encodes the given `string` with the standard Base 32 alphabet as defined in section 6 of RFC 4648.
    ///
    /// If the given `string` is empty, the encoded `String` will also be empty. The  result can contain padding (`=`),
    /// if the given `string` does not contain a multiple of 5 input characters.
    ///
    /// **Examples:**
    ///
    /// ```
    /// let encoded = Base32.encode(string: "foobar")
    /// print(encoded) // prints "MZXW6YTBOI======"
    /// ```
    ///
    /// - Parameter string: The  string to encode.
    ///
    /// - Returns: Base 32 encoded `String` or empty `String` if the given `string` is empty.
    ///
    /// - Important: This method is case insensitive.
    public static func encode(string: String) -> String {
        if string.isEmpty {
            return ""
        }

        return encode(bytes: Array(string.utf8), alphabet: Alphabet.base32)
    }

    /// Encodes the given `string` with the "Extended Hex" Base 32 alphabet as defined in section 7 of RFC 4648.
    ///
    /// If the given `string` is empty, the encoded `String` will also be empty. The  result can contain padding (`=`),
    /// if the given `string` does not contain a multiple of 5 input characters.
    ///
    /// **Examples:**
    ///
    /// ```
    /// let encoded = Base32.encodeHex(string: "foobar")
    /// print(encoded) // prints "CPNMUOJ1E8======"
    /// ```
    ///
    /// - Parameter string: The string to encode.
    ///
    /// - Returns: Base 32 Hex encoded `String` or empty `String` if the given `string` is empty.
    ///
    /// - Important: This method is case insensitive.
    public static func encodeHex(string: String) -> String {
        if string.isEmpty {
            return ""
        }

        return encode(bytes: Array(string.utf8), alphabet: Alphabet.base32hex)
    }

    /// Decodes the given `string` with the standard Base 32 alphabet.
    ///
    /// If the given `string` is empty, the decoded `String` will also be empty. This method is case in-senstive.
    ///
    /// **Examples:**
    ///
    /// ```
    /// if let decoded = try? Base32.decode(string: "MZXW6YTBOI======") {
    ///     print(decoded) // prints "foobar"
    /// }
    /// ```
    ///
    /// - Parameter string: The  string to decode.
    ///
    /// - Returns: Decoded string or empty `String` if the given `string` is empty.
    ///
    /// - Important: This method is case insensitive.
    ///
    /// - Throws:
    ///     - `Base32.DecodingError.invalidLength`
    ///        if the encoded string has invalid length (is not a multiple of 8 or empty).
    ///     - `Base32.DecodingError.illegalCharactersFound`
    ///        if the encoded string contains one or more illegal characters.
    ///     - `Base32.DecodingError.invalidPaddingCharacters`
    ///        if the encoded string contains a padding character (`=`) at an illegal position.
    ///     - `Base32.DecodingError.missingCharacter`
    ///        if no character can be read even though there a character is expected.
    public static func decode(string: String) throws -> String {
        if string.isEmpty {
            return ""
        }

        try validate(string: string, legalCharacters: "ABCDEFGHIJKLMNOPQRSRTUVWXYZabcdefghiklmnopqrstuvwxyz234567=")

        return try decode(bytes: Array(string.utf8), alphabet: decodeBase32)
    }

    /// Decodes the given `string` with the "Extended Hex" Base 32 alphabet.
    ///
    /// If the given `string` is empty, the decoded `String` will also be empty.
    ///
    /// **Examples:**
    ///
    /// ```
    /// if let decoded = try? Base32.decodeHex(string: "CPNMUOJ1E8======") {
    ///     print(decoded) // prints "foobar"
    /// }
    /// ```
    ///
    /// - Parameter string: The string to decode.
    ///
    /// - Returns: Decoded  string or empty `String` if the given `string` is empty.
    ///
    /// - Important: This method is case insensitive.
    ///
    /// - Throws:
    ///     - `Base32.DecodingError.invalidLength`
    ///        if the encoded string has invalid length (is not a multiple of 8 or empty).
    ///     - `Base32.DecodingError.illegalCharactersFound`
    ///        if the encoded string contains one or more illegal characters.
    ///     - `Base32.DecodingError.invalidPaddingCharacters`
    ///        if the encoded string contains a padding character (`=`) at an illegal position.
    ///     - `Base32.DecodingError.missingCharacter`
    ///        if no character can be read even though there a character is expected.
    public static func decodeHex(string: String) throws -> String {
        if string.isEmpty {
            return ""
        }

        try validate(string: string, legalCharacters: "ABCDEFGHIJKLMNOPQRSTUVabcdefghijklmnopqrstuv0123456789=")

        return try decode(bytes: Array(string.utf8), alphabet: decodeBase32hex)
    }
}

extension Base32 {
    private static func encode<Buffer: Collection>(bytes: Buffer, alphabet: [UInt8]) -> String
        where Buffer.Element == UInt8 {
        var encoded = [UInt8]()
        let capacity = ((bytes.count + 4) / 5) * 8
        encoded.reserveCapacity(capacity)

        var input = bytes.makeIterator()
        while let firstByte = input.next() {
            let secondByte = input.next()
            let thirdByte = input.next()
            let fourthByte = input.next()
            let fifthByte = input.next()

            let firstChar = Base32.encode(alphabet: alphabet, firstByte: firstByte)
            let secondChar = Base32.encode(alphabet: alphabet, firstByte: firstByte, secondByte: secondByte)
            let thirdChar = Base32.encode(alphabet: alphabet, secondByte: secondByte)
            let fourthChar = Base32.encode(alphabet: alphabet, secondByte: secondByte, thirdByte: thirdByte)
            let fifthChar = Base32.encode(alphabet: alphabet, thirdByte: thirdByte, fourthByte: fourthByte)
            let sixthChar = Base32.encode(alphabet: alphabet, fourthByte: fourthByte)
            let seventhChar = Base32.encode(alphabet: alphabet, fourthByte: fourthByte, fifthByte: fifthByte)
            let eightChar = Base32.encode(alphabet: alphabet, fifthByte: fifthByte)

            encoded.append(firstChar)
            encoded.append(secondChar)
            encoded.append(thirdChar)
            encoded.append(fourthChar)
            encoded.append(fifthChar)
            encoded.append(sixthChar)
            encoded.append(seventhChar)
            encoded.append(eightChar)
        }

        return String(decoding: encoded, as: Unicode.UTF8.self)
    }

    private static func encode(alphabet: [UInt8], firstByte: UInt8) -> UInt8 {
        let index = firstByte >> 3
        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], firstByte: UInt8, secondByte: UInt8?) -> UInt8 {
        var index = (firstByte & 0b0000_0111) << 2

        if let secondByte = secondByte {
            index |= (secondByte & 0b1100_0000) >> 6
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], secondByte: UInt8?) -> UInt8 {
        guard let secondByte = secondByte else {
            return Alphabet.encodePaddingCharacter
        }

        let index = (secondByte & 0b0011_1110) >> 1
        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], secondByte: UInt8?, thirdByte: UInt8?) -> UInt8 {
        guard let secondByte = secondByte else {
            return Alphabet.encodePaddingCharacter
        }

        var index = (secondByte & 0b0000_0001) << 4

        if let thirdByte = thirdByte {
            index |= (thirdByte & 0b1111_0000) >> 4
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], thirdByte: UInt8?, fourthByte: UInt8?) -> UInt8 {
        guard let thirdByte = thirdByte else {
            return Alphabet.encodePaddingCharacter
        }

        var index = (thirdByte & 0b0000_1111) << 1

        if let fourthByte = fourthByte {
            index |= (fourthByte & 0b1000_0000) >> 7
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fourthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return Alphabet.encodePaddingCharacter
        }

        let index = (fourthByte & 0b0111_1100) >> 2
        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fourthByte: UInt8?, fifthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return Alphabet.encodePaddingCharacter
        }

        var index = (fourthByte & 0b0000_0011) << 3

        if let fifthByte = fifthByte {
            index |= (fifthByte & 0b1110_0000) >> 5
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fifthByte: UInt8?) -> UInt8 {
        guard let fifthByte = fifthByte else {
            return Alphabet.encodePaddingCharacter
        }

        let index = fifthByte & 0b0001_1111
        return alphabet[Int(index)]
    }
}

extension Base32 {
    struct DecodingOptions: OptionSet {
        let rawValue: UInt8

        static let requiredPadding = DecodingOptions(rawValue: 1 << 0)

        static let strictMode: DecodingOptions = [.requiredPadding]
    }

    private static func decode<Buffer: Collection>(bytes: Buffer, alphabet: [UInt8]) throws -> String
        where Buffer.Element == UInt8 {
        let characterCount = bytes.count
        let inputBlocks = characterCount / 8
        let blocksWithoutPadding = inputBlocks - 1

        var output = [UInt8]()
        var input = bytes.makeIterator()

        for _ in 0 ..< blocksWithoutPadding {
            let firstValue = try input.nextValue(alphabet: alphabet)
            let secondValue = try input.nextValue(alphabet: alphabet)
            let thirdValue = try input.nextValue(alphabet: alphabet)
            let fourthValue = try input.nextValue(alphabet: alphabet)
            let fifthValue = try input.nextValue(alphabet: alphabet)
            let sixthValue = try input.nextValue(alphabet: alphabet)
            let seventhValue = try input.nextValue(alphabet: alphabet)
            let eightValue = try input.nextValue(alphabet: alphabet)

            output.append((firstValue << 3) | (secondValue >> 2))
            output.append((secondValue << 6) | (thirdValue << 1) | (fourthValue >> 4))
            output.append((fourthValue << 4) | (fifthValue >> 1))
            output.append((fifthValue << 7) | (sixthValue << 2) | (seventhValue >> 3))
            output.append((seventhValue << 5) | eightValue)
        }

        let firstByte = try input.nextValue(alphabet: alphabet)
        let secondByte = try input.nextValue(alphabet: alphabet)

        let value = (firstByte << 3) | (secondByte >> 2)
        output.append(value)

        let thirdByte = input.nextValueOrEmpty(alphabet: alphabet)
        let fourthByte = input.nextValueOrEmpty(alphabet: alphabet)

        if thirdByte != nil, fourthByte != nil {
            let value = (secondByte << 6) | (thirdByte! << 1) | (fourthByte! >> 4)
            output.append(value)
        }

        let fifthByte = input.nextValueOrEmpty(alphabet: alphabet)

        if fifthByte != nil {
            let value = (fourthByte! << 4) | (fifthByte! >> 1)
            output.append(value)
        }

        let sixthByte = input.nextValueOrEmpty(alphabet: alphabet)
        let seventhByte = input.nextValueOrEmpty(alphabet: alphabet)

        if sixthByte != nil, seventhByte != nil {
            let value = (fifthByte! << 7) | (sixthByte! << 2) | (seventhByte! >> 3)
            output.append(value)
        }

        let eightByte = input.nextValueOrEmpty(alphabet: alphabet)
        if eightByte != nil {
            let value = (seventhByte! << 5) | eightByte!
            output.append(value)
        }

        return String(decoding: output, as: Unicode.UTF8.self)
    }
}

extension IteratorProtocol where Self.Element == UInt8 {
    mutating func nextValue(alphabet: [UInt8]) throws -> UInt8 {
        guard let ascii = next() else {
            throw Base32.DecodingError.missingCharacter
        }

        return alphabet[Int(ascii)]
    }

    mutating func nextValueOrEmpty(alphabet: [UInt8]) -> UInt8? {
        guard let ascii = next() else {
            return nil
        }

        if ascii == Alphabet.encodePaddingCharacter {
            return nil
        }

        return alphabet[Int(ascii)]
    }
}
