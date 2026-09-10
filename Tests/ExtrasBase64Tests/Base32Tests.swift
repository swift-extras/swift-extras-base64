import ExtrasBase64
import Testing

@Suite
struct Base32Tests {
    // MARK: Encoding

    @Test
    func encodeEmptyData() {
        let data = [UInt8]()
        let encodedData: [UInt8] = Base32.encodeToBytes(bytes: data)
        #expect(encodedData.count == 0)
    }

    @Test
    func base32EncodingArrayOfNulls() {
        let data = Array(repeating: UInt8(0), count: 10)
        let encodedData: [UInt8] = Base32.encodeToBytes(bytes: data)
        #expect(encodedData == [UInt8]("AAAAAAAAAAAAAAAA".utf8))
    }

    @Test
    func base32EncodingAllTheBytesSequentially() {
        let data = Array(UInt8(0)...UInt8(255))
        let encodedData = Base32.encodeToBytes(bytes: data)
        #expect(
            encodedData
                == [UInt8](
                    "AAAQEAYEAUDAOCAJBIFQYDIOB4IBCEQTCQKRMFYYDENBWHA5DYPSAIJCEMSCKJRHFAUSUKZMFUXC6MBRGIZTINJWG44DSOR3HQ6T4P2AIFBEGRCFIZDUQSKKJNGE2TSPKBIVEU2UKVLFOWCZLJNVYXK6L5QGCYTDMRSWMZ3INFVGW3DNNZXXA4LSON2HK5TXPB4XU634PV7H7AEBQKBYJBMGQ6EITCULRSGY5D4QSGJJHFEVS2LZRGM2TOOJ3HU7UCQ2FI5EUWTKPKFJVKV2ZLNOV6YLDMVTWS23NN5YXG5LXPF5X274BQOCYPCMLRWHZDE4VS6MZXHM7UGR2LJ5JVOW27MNTWW33TO55X7A4HROHZHF43T6R2PK5PWO33XP6DY7F47U6X3PP6HZ7L57Z7P674======"
                        .utf8))
    }

    // MARK: Decoding

    @Test
    func decodeEmptyString() throws {
        let decoded = try Base32.decode(string: "")
        #expect(decoded.count == 0)
    }

    @Test
    func decodeEmptyBytes() throws {
        let decoded = try Base32.decode(bytes: [])
        #expect(decoded.count == 0)
    }

    @Test
    func base32DecodingArrayOfNulls() throws {
        let expected = Array(repeating: UInt8(0), count: 10)
        var string = "AAAAAAAAAAAAAAAAA"
        string.makeContiguousUTF8()
        #expect(try Base32.decode(string: string) == expected)
    }

    @Test
    func base32DecodingAllTheBytesSequentially() throws {
        let base32 =
            "AAAQEAYEAUDAOCAJBIFQYDIOB4IBCEQTCQKRMFYYDENBWHA5DYPSAIJCEMSCKJRHFAUSUKZMFUXC6MBRGIZTINJWG44DSOR3HQ6T4P2AIFBEGRCFIZDUQSKKJNGE2TSPKBIVEU2UKVLFOWCZLJNVYXK6L5QGCYTDMRSWMZ3INFVGW3DNNZXXA4LSON2HK5TXPB4XU634PV7H7AEBQKBYJBMGQ6EITCULRSGY5D4QSGJJHFEVS2LZRGM2TOOJ3HU7UCQ2FI5EUWTKPKFJVKV2ZLNOV6YLDMVTWS23NN5YXG5LXPF5X274BQOCYPCMLRWHZDE4VS6MZXHM7UGR2LJ5JVOW27MNTWW33TO55X7A4HROHZHF43T6R2PK5PWO33XP6DY7F47U6X3PP6HZ7L57Z7P674"

        let expected = Array(UInt8(0)...UInt8(255))
        #expect(try Base32.decode(bytes: base32.utf8) == expected)
    }

    @Test
    func base32DecodingWithNullCharacters() throws {
        let base32 = """
            AAAQEAYEAUDAOCAJBIFQYDIOB4IBCEQTCQKRMFYYDENBWHA5D
            YPSAIJCEMSCKJRHFAUSUKZMFUXC6MBRGIZTINJWG44DSOR3HQ
            6T4P2AIFBEGRCFIZDUQSKKJNGE2TSPKBIVEU2UKVLFOWCZLJN
            VYXK6L5QGCYTDMRSWMZ3INFVGW3DNNZXXA4LSON2HK5TXPB4X
            U634PV7H7AEBQKBYJBMGQ6EITCULRSGY5D4QSGJJHFEVS2LZR
            GM2TOOJ3HU7UCQ2FI5EUWTKPKFJVKV2ZLNOV6YLDMVTWS23NN
            5YXG5LXPF5X274BQOCYPCMLRWHZDE4VS6MZXHM7UGR2LJ5JVO
            W27MNTWW33TO55X7A4HROHZHF43T6R2PK5PWO33XP6DY7F47U
            6X3PP6HZ7L57Z7P674
            """

        let expected = Array(UInt8(0)...UInt8(255))
        #expect(try Base32.decode(bytes: base32.utf8, options: .allowNullCharacters) == expected)
        #expect(throws: Base32.DecodingError.invalidCharacter) {
            _ = try Base32.decode(bytes: base32.utf8)
        }
    }

    @Test
    func base32DecodingWithPoop() {
        #expect(throws: Base32.DecodingError.invalidCharacter) {
            _ = try Base32.decode(bytes: "💩".utf8)
        }
    }

    @Test
    func base32DecodingOneTwoThreeFour() throws {
        let base32 = "AEBAGBA="
        let bytes: [UInt8] = [1, 2, 3, 4]

        #expect(Base32.encodeToString(bytes: bytes) == base32)
        #expect(try Base32.decode(string: base32) == bytes)
    }

    @Test
    func base32DecodingOneTwoThreeFourFive() throws {
        let base32 = "AEBAGBAF"
        let bytes: [UInt8] = [1, 2, 3, 4, 5]

        #expect(Base32.encodeToString(bytes: bytes) == base32)
        #expect(try Base32.decode(string: base32) == bytes)
    }

    @Test
    func base32DecodingOneTwoThreeFourFiveSix() throws {
        let base32 = "AEBAGBAFAY"
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]

        #expect(Base32.encodeToString(bytes: bytes, options: .omitPaddingCharacter) == base32)
        #expect(try Base32.decode(string: base32) == bytes)
    }

    @Test
    func base32DecodingPadding() throws {
        let base32 = "AEBAGBAFAY======"
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]

        #expect(Base32.encodeToString(bytes: bytes) == base32)
        #expect(try base32.base32decoded() == bytes)
    }

    @Test
    func base32EncodeFoobar() {
        #expect(String(base32Encoding: "".utf8, options: .omitPaddingCharacter) == "")
        #expect(String(base32Encoding: "f".utf8, options: .omitPaddingCharacter) == "MY")
        #expect(String(base32Encoding: "fo".utf8, options: .omitPaddingCharacter) == "MZXQ")
        #expect(String(base32Encoding: "foo".utf8, options: .omitPaddingCharacter) == "MZXW6")
        #expect(String(base32Encoding: "foob".utf8, options: .omitPaddingCharacter) == "MZXW6YQ")
        #expect(String(base32Encoding: "fooba".utf8, options: .omitPaddingCharacter) == "MZXW6YTB")
        #expect(String(base32Encoding: "foobar".utf8, options: .omitPaddingCharacter) == "MZXW6YTBOI")
    }

    @Test
    func base32EncodeFoobarWithPadding() {
        #expect(String(base32Encoding: "f".utf8) == "MY======")
        #expect(String(base32Encoding: "fo".utf8) == "MZXQ====")
        #expect(String(base32Encoding: "foo".utf8) == "MZXW6===")
        #expect(String(base32Encoding: "foob".utf8) == "MZXW6YQ=")
        #expect(String(base32Encoding: "fooba".utf8) == "MZXW6YTB")
        #expect(String(base32Encoding: "foobar".utf8) == "MZXW6YTBOI======")
    }

    @Test
    func base32DecodeFoobar() throws {
        #expect(try "".base32decoded() == .init("".utf8))
        #expect(try "MY".base32decoded() == .init("f".utf8))
        #expect(try "MZXQ".base32decoded() == .init("fo".utf8))
        #expect(try "MZXW6".base32decoded() == .init("foo".utf8))
        #expect(try "MZXW6YQ".base32decoded() == .init("foob".utf8))
        #expect(try "MZXW6YTB".base32decoded() == .init("fooba".utf8))
        #expect(try "MZXW6YTBOI".base32decoded() == .init("foobar".utf8))
    }

    @Test
    func base32DecodeFoobarWithPadding() throws {
        #expect(try "MY======".base32decoded() == .init("f".utf8))
        #expect(try "MZXQ====".base32decoded() == .init("fo".utf8))
        #expect(try "MZXW6===".base32decoded() == .init("foo".utf8))
        #expect(try "MZXW6YQ=".base32decoded() == .init("foob".utf8))
        #expect(try "MZXW6YTB".base32decoded() == .init("fooba".utf8))
        #expect(try "MZXW6YTBOI======".base32decoded() == .init("foobar".utf8))
    }

    @Test(arguments: 0..<100)
    func base32EncodeDecode(iteration: Int) throws {
        let buffer: [UInt8] = (0..<Int.random(in: 1..<8192)).map { _ in UInt8.random(in: .min ... .max) }
        let base32 = String(base32Encoding: buffer)
        #expect(try base32.base32decoded(options: .allowNullCharacters) == buffer)
        #expect(try base32.base32decoded() == buffer)
    }

    // MARK: - Span APIs

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test(arguments: [Base32.EncodingOptions(), .omitPaddingCharacter])
    func encodeIntoSpansMatchesEncodeToBytes(options: Base32.EncodingOptions) {
        // Lengths 0...9 cover every remainder class mod 5, which is where the
        // unpadded length calculation differs from the padded one.
        for length in 0...9 {
            let bytes = (0..<length).map { UInt8(truncatingIfNeeded: $0 &* 7 &+ 1) }
            let expected = Base32.encodeToBytes(bytes: bytes, options: options)
            let capacity = Base32.encodedLength(bytesCount: length, options: options)

            // Exactly-sized buffer: also pins `encodedLength` against the encoder.
            var storage = [UInt8](repeating: 0, count: capacity)
            let written = bytes.withUnsafeBufferPointer { input -> Int in
                var output = storage.mutableSpan
                return Base32.encode(bytes: input.span, into: &output, options: options)
            }
            #expect(written == expected.count, "length \(length)")
            #expect(storage == expected, "length \(length)")

            let appended = [UInt8](capacity: capacity) { (output: inout OutputSpan<UInt8>) in
                bytes.withUnsafeBufferPointer { input in
                    _ = Base32.encode(bytes: input.span, into: &output, options: options)
                }
            }
            #expect(appended == expected, "length \(length)")
        }
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test
    func encodeIntoSpansPreservesSurroundingBytes() {
        let prefix: [UInt8] = [UInt8(ascii: "x"), UInt8(ascii: "y")]
        let bytes: [UInt8] = [1, 2, 3, 4, 5]
        let expected = Base32.encodeToBytes(bytes: bytes)

        var written = 0
        let appended = [UInt8](capacity: prefix.count + expected.count) { (output: inout OutputSpan<UInt8>) in
            for byte in prefix { output.append(byte) }
            bytes.withUnsafeBufferPointer { input in
                written = Base32.encode(bytes: input.span, into: &output)
            }
        }
        #expect(written == expected.count)
        #expect(appended == prefix + expected)

        var storage = [UInt8](repeating: 0xAA, count: expected.count + 16)
        let count = bytes.withUnsafeBufferPointer { input -> Int in
            var output = storage.mutableSpan
            return Base32.encode(bytes: input.span, into: &output)
        }
        #expect(Array(storage[..<count]) == expected)
        #expect(storage[count...].allSatisfy { $0 == 0xAA })
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test
    func decodeIntoSpansMatchesDecode() throws {
        let expected = Array(UInt8(0)...UInt8(255))
        let encoded = Base32.encodeToBytes(bytes: expected)
        let capacity = ((encoded.count + 7) / 8) * 5

        var storage = [UInt8](repeating: 0, count: capacity)
        let written = try encoded.withUnsafeBufferPointer { input -> Int in
            var output = storage.mutableSpan
            return try Base32.decode(bytes: input.span, into: &output)
        }
        #expect(written == expected.count)
        #expect(Array(storage[..<written]) == expected)

        let appended = try [UInt8](capacity: capacity) { (output: inout OutputSpan<UInt8>) in
            try encoded.withUnsafeBufferPointer { input in
                _ = try Base32.decode(bytes: input.span, into: &output)
            }
        }
        #expect(appended == expected)
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test(arguments: [Base32.DecodingOptions(), .allowNullCharacters])
    func decodeIntoOutputSpanPreservesExistingPrefix(options: Base32.DecodingOptions) throws {
        let prefix: [UInt8] = [UInt8(ascii: "x"), UInt8(ascii: "y")]
        let expected: [UInt8] = [1, 2, 3, 4, 5]
        let encoded = Base32.encodeToBytes(bytes: expected)

        var written = 0
        let capacity = prefix.count + ((encoded.count + 7) / 8) * 5
        let appended = try [UInt8](capacity: capacity) { (output: inout OutputSpan<UInt8>) in
            for byte in prefix { output.append(byte) }
            try encoded.withUnsafeBufferPointer { input in
                written = try Base32.decode(bytes: input.span, into: &output, options: options)
            }
        }

        #expect(written == expected.count)
        #expect(appended == prefix + expected)
    }
}
