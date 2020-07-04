/// The `Base32` struct contains methods to encode and decode data using the Base 32 encoding as defined
/// by [RFC 4648](https://tools.ietf.org/html/rfc4648).
///
/// The API supports both alphabets defined in the specification for encoding and decoding data:
///
/// 1. The Base 32 Alphabet (see [RFC 4648 Section 6](https://tools.ietf.org/html/rfc4648#section-6))
/// 2. The "Extended Hex" Base 32 Alphabet (see [RFC 4648 Section 7](https://tools.ietf.org/html/rfc4648#section-7))
///
/// The API encodes from a byte array to a `String` and decodes from a `String` to a byte array. This
/// allows encoding of arbitrary data. All the inputs are validated and the API will throw exceptions
/// instead of ignoring illegal input.
///
/// All methods are `static` so no instance of the `Base32` struct needs to be created.
///
/// **Examples:**
///
/// ```
/// let encoded = Base32.encode(bytes: Array("foobar".utf8))
/// print(encoded) // prints "MZXW6YTBOI======"
///
/// if let decoded = try? Base32.decode(encoded: "MZXW6YTBOI======") {
///     print(decoded) // prints "foobar"
/// }
/// ```
///
/// - Note: Encoding and decoding methods are not optimized and might perform badly. Use another Swift package if
///         performance is your primary concern.
/// - Warning: This API is still under development. APIs are subject to change and error. Do not use in production.
public struct Base32 {
    /// Encodes the given bytes with the given Base 32 alphabet as defined in section 6 of RFC 4648.
    ///
    /// If the given bytes are empty, the encoded `String` will also be empty. The result can contain padding (`=`),
    /// if the length of the given bytes is not a multiple of 5.
    ///
    /// **Examples:**
    ///
    /// ```
    /// let encoded = Base32.encode(bytes: Array("foobar".utf8))
    /// print(encoded) // prints "MZXW6YTBOI======"
    /// ```
    ///
    /// ```
    /// let encoded = Base32.encode(bytes: Array("foobar".utf8), alphabet: .hex)
    /// print(encoded) // prints "CPNMUOJ1E8======"
    /// ```
    ///
    /// - Parameter bytes: The bytes to encode.
    /// - Parameter alphabet: The alphabet to use for encoding (optional, default: standard).
    ///
    /// - Returns: Base 32 encoded `String` or empty `String` if the given bytes are empty.
    public static func encode<Buffer: Collection>(bytes: Buffer, alphabet: Alphabet = .standard) -> String where Buffer.Element == UInt8 {
        if bytes.isEmpty {
            return ""
        }

        let encodingTable = encodingTables[alphabet]!

        var output = [UInt8]()
        let capacity = ((bytes.count + 4) / 5) * 8
        output.reserveCapacity(capacity)

        var input = bytes.makeIterator()
        while
            let byte1 = input.next() {
            let byte2 = input.next()
            let byte3 = input.next()
            let byte4 = input.next()
            let byte5 = input.next()

            let char1 = Base32.encode(alphabet: encodingTable, firstByte: byte1)
            let char2 = Base32.encode(alphabet: encodingTable, firstByte: byte1, secondByte: byte2)
            let char3 = Base32.encode(alphabet: encodingTable, secondByte: byte2)
            let char4 = Base32.encode(alphabet: encodingTable, secondByte: byte2, thirdByte: byte3)
            let char5 = Base32.encode(alphabet: encodingTable, thirdByte: byte3, fourthByte: byte4)
            let char6 = Base32.encode(alphabet: encodingTable, fourthByte: byte4)
            let char7 = Base32.encode(alphabet: encodingTable, fourthByte: byte4, fifthByte: byte5)
            let char8 = Base32.encode(alphabet: encodingTable, fifthByte: byte5)

            output.append(char1)
            output.append(char2)
            output.append(char3)
            output.append(char4)
            output.append(char5)
            output.append(char6)
            output.append(char7)
            output.append(char8)
        }

        return String(decoding: output, as: Unicode.UTF8.self)
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
            return encodePaddingCharacter
        }

        let index = (secondByte & 0b0011_1110) >> 1
        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], secondByte: UInt8?, thirdByte: UInt8?) -> UInt8 {
        guard let secondByte = secondByte else {
            return encodePaddingCharacter
        }

        var index = (secondByte & 0b0000_0001) << 4

        if let thirdByte = thirdByte {
            index |= (thirdByte & 0b1111_0000) >> 4
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], thirdByte: UInt8?, fourthByte: UInt8?) -> UInt8 {
        guard let thirdByte = thirdByte else {
            return encodePaddingCharacter
        }

        var index = (thirdByte & 0b0000_1111) << 1

        if let fourthByte = fourthByte {
            index |= (fourthByte & 0b1000_0000) >> 7
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fourthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return encodePaddingCharacter
        }

        let index = (fourthByte & 0b0111_1100) >> 2
        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fourthByte: UInt8?, fifthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return encodePaddingCharacter
        }

        var index = (fourthByte & 0b0000_0011) << 3

        if let fifthByte = fifthByte {
            index |= (fifthByte & 0b1110_0000) >> 5
        }

        return alphabet[Int(index)]
    }

    private static func encode(alphabet: [UInt8], fifthByte: UInt8?) -> UInt8 {
        guard let fifthByte = fifthByte else {
            return encodePaddingCharacter
        }

        let index = fifthByte & 0b0001_1111
        return alphabet[Int(index)]
    }
}

extension Base32 {
    /// Decodes the given `String` with the given Base 32 alphabet.
    ///
    /// If the given `String` is empty, the decoded bytes will also be empty. This method is case in-senstive.
    ///
    /// **Examples:**
    ///
    /// ```
    /// if let decoded = try? Base32.decode(encoded: "MZXW6YTBOI======") {
    ///     print(decoded) // prints "foobar"
    /// }
    /// ```
    ///
    /// ```
    /// if let decoded = try? Base32.decode(string: "CPNMUOJ1E8======", alphabet: .hex) {
    ///     print(decoded) // prints "foobar"
    /// }
    /// ```
    ///
    /// - Parameter encoded: The string to decode.
    /// - Parameter alphabet: The alphabet to use for decoding (optional, default: standard).
    ///
    /// - Returns: Decoded bytes or empty byte array if the given `String` is empty.
    ///
    /// - Important: This method is case in-sensitive.
    ///
    /// - Throws:
    ///     - `DecodingError.invalidLength`
    ///        if the encoded string has invalid length (is not a multiple of 8 or empty).
    ///     - `DecodingError.illegalCharacter`
    ///        if the encoded string contains an illegal character.
    ///     - `DecodingError.unexpectedPaddingCharacter`
    ///        if the encoded string contains a padding character (`=`) at an illegal position.
    ///     - `DecodingError.missingCharacter`
    ///        if no character can be read even though there a character is expected.
    public static func decode(encoded: String, alphabet: Alphabet = .standard) throws -> [UInt8] {
        if encoded.isEmpty {
            return []
        }

        guard encoded.count % 8 == 0 else {
            throw DecodingError.invalidLength
        }

        let bytes = Array(encoded.utf8)

        // let characterCount = bytes.count
        let characterCount = encoded.count
        let inputBlocks = characterCount / 8
        let blocksWithoutPadding = inputBlocks - 1

        let encodingTable = decodingTables[alphabet]!
        var output = [UInt8]()
        var input = bytes.makeIterator()

        for _ in 0 ..< blocksWithoutPadding {
            let value1 = try input.nextBase32Value(alphabet: encodingTable)
            let value2 = try input.nextBase32Value(alphabet: encodingTable)
            let value3 = try input.nextBase32Value(alphabet: encodingTable)
            let value4 = try input.nextBase32Value(alphabet: encodingTable)
            let value5 = try input.nextBase32Value(alphabet: encodingTable)
            let value6 = try input.nextBase32Value(alphabet: encodingTable)
            let value7 = try input.nextBase32Value(alphabet: encodingTable)
            let value8 = try input.nextBase32Value(alphabet: encodingTable)

            output.append((value1 << 3) | (value2 >> 2))
            output.append((value2 << 6) | (value3 << 1) | (value4 >> 4))
            output.append((value4 << 4) | (value5 >> 1))
            output.append((value5 << 7) | (value6 << 2) | (value7 >> 3))
            output.append((value7 << 5) | value8)
        }

        let firstByte = try input.nextBase32Value(alphabet: encodingTable)
        let secondByte = try input.nextBase32Value(alphabet: encodingTable)

        let value = (firstByte << 3) | (secondByte >> 2)
        output.append(value)

        let thirdByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)
        let fourthByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)

        if thirdByte != nil, fourthByte != nil {
            let value = (secondByte << 6) | (thirdByte! << 1) | (fourthByte! >> 4)
            output.append(value)
        }

        let fifthByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)

        if fourthByte != nil, fifthByte != nil {
            let value = (fourthByte! << 4) | (fifthByte! >> 1)
            output.append(value)
        }

        let sixthByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)
        let seventhByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)

        if fifthByte != nil, sixthByte != nil, seventhByte != nil {
            let value = (fifthByte! << 7) | (sixthByte! << 2) | (seventhByte! >> 3)
            output.append(value)
        }

        let eightByte = try input.nextBase32ValueOrEmpty(alphabet: encodingTable)
        if seventhByte != nil, eightByte != nil {
            let value = (seventhByte! << 5) | eightByte!
            output.append(value)
        }

        return output
    }
}

extension IteratorProtocol where Self.Element == UInt8 {
    mutating func nextBase32Value(alphabet: [UInt8]) throws -> UInt8 {
        guard let ascii = next() else {
            throw DecodingError.missingCharacter
        }

        let char = alphabet[Int(ascii)]
        guard char != 255 else {
            throw DecodingError.illegalCharacter
        }

        if ascii == Base32.encodePaddingCharacter {
            throw DecodingError.unexpectedPaddingCharacter
        }

        return char
    }

    mutating func nextBase32ValueOrEmpty(alphabet: [UInt8]) throws -> UInt8? {
        guard let ascii = next() else {
            return nil
        }

        if ascii == Base32.encodePaddingCharacter {
            return nil
        }

        let char = alphabet[Int(ascii)]
        guard char != 255 else {
            throw DecodingError.illegalCharacter
        }

        return char
    }
}
