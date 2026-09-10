import ExtrasBase64
import Foundation
import Testing

@Suite
struct ChromiumTests {
    // MARK: Encoding

    @Test
    func encodeEmptyData() {
        let data = [UInt8]()
        let encodedData: [UInt8] = Base64.encodeToBytes(bytes: data)
        #expect(encodedData.count == 0)
    }

    @Test
    func base64EncodingArrayOfNulls() {
        let data = Array(repeating: UInt8(0), count: 10)
        let encodedData: [UInt8] = Base64.encodeToBytes(bytes: data)
        #expect(encodedData == [UInt8]("AAAAAAAAAAAAAA==".utf8))
    }

    @Test
    func base64EncodingAllTheBytesSequentially() {
        let data = Array(UInt8(0)...UInt8(255))
        let encodedData: [UInt8] = Base64.encodeToBytes(bytes: data)
        #expect(
            encodedData
                == [UInt8](
                    "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="
                        .utf8))
    }

    @Test
    func base64UrlEncodingAllTheBytesSequentially() {
        let data = Array(UInt8(0)...UInt8(255))
        let encodedData: [UInt8] = Base64.encodeToBytes(bytes: data, options: .base64UrlAlphabet)
        #expect(
            encodedData
                == [UInt8](
                    "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w=="
                        .utf8))
    }

    @Test
    func base64UrlEncodingAllTheBytesSequentiallyOmitPadding() {
        let data = Array(UInt8(0)...UInt8(255))
        let encodedData: [UInt8] = Base64.encodeToBytes(bytes: data, options: [.base64UrlAlphabet, .omitPaddingCharacter])
        #expect(
            encodedData
                == [UInt8](
                    "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w"
                        .utf8))
    }

    // MARK: Decoding

    @Test
    func decodeEmptyString() throws {
        var decoded: [UInt8]?
        #expect(throws: Never.self) {
            decoded = try Base64.decode(string: "")
        }
        #expect(decoded?.count == 0)
    }

    @Test
    func decodeEmptyBytes() throws {
        var decoded: [UInt8]?
        #expect(throws: Never.self) {
            decoded = try Base64.decode(bytes: [])
        }
        #expect(decoded?.count == 0)
    }

    @Test
    func base64DecodingArrayOfNulls() throws {
        let expected = Array(repeating: UInt8(0), count: 10)
        var decoded: [UInt8]?
        var string = "AAAAAAAAAAAAAA=="
        string.makeContiguousUTF8()
        #expect(throws: Never.self) {
            decoded = try Base64.decode(string: string)
        }
        #expect(decoded == expected)
    }

    @Test
    func base64DecodingAllTheBytesSequentially() {
        let base64 =
            "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="

        let expected = Array(UInt8(0)...UInt8(255))
        var decoded: [UInt8]?
        #expect(throws: Never.self) {
            decoded = try Base64.decode(bytes: base64.utf8)
        }
        #expect(decoded == expected)
    }

    @Test
    func base64UrlDecodingAllTheBytesSequentially() {
        let base64 =
            "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w=="

        let expected = Array(UInt8(0)...UInt8(255))
        var decoded: [UInt8]?
        #expect(throws: Never.self) {
            decoded = try Base64.decode(string: base64, options: .base64UrlAlphabet)
        }

        #expect(decoded == expected)
    }

    @Test
    func base64UrlDecodingAllTheBytesSequentiallyOmitPadding() {
        let base64 =
            "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w"

        let expected = Array(UInt8(0)...UInt8(255))
        var decoded: [UInt8]?
        #expect(throws: Never.self) {
            decoded = try Base64.decode(string: base64, options: [.base64UrlAlphabet, .omitPaddingCharacter])
        }

        #expect(decoded == expected)
    }

    @Test
    func base64DecodingWithPoop() {
        #expect(throws: Base64.DecodingError.invalidCharacter(240)) {
            _ = try Base64.decode(bytes: "💩".utf8)
        }
    }

    @Test(arguments: [
        ("AQIDBA==", [1, 2, 3, 4]),
        ("AQIDBAU=", [1, 2, 3, 4, 5]),
        ("AQIDBAUG", [1, 2, 3, 4, 5, 6]),
    ])
    func base64DecodingVariousMessages(base64: String, bytes: [UInt8]) throws {
        #expect(Base64.encodeToString(bytes: bytes) == base64)
        #expect(try Base64.decode(string: base64) == bytes)
    }

    @Test
    func base64DecodingWithInvalidLength() {
        #expect(throws: Base64.DecodingError.invalidLength) {
            _ = try Base64.decode(bytes: "AAAAA".utf8)
        }
    }

    @Test
    func decodeNSString() {
        let test = "1234567"
        let nsstring = test.data(using: .utf8)!.base64EncodedString()

        #expect(throws: Never.self) { try Base64.decode(string: nsstring) }
    }

    // MARK: - Span APIs

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test(arguments: [Base64.EncodingOptions(), .base64UrlAlphabet, .omitPaddingCharacter, [.base64UrlAlphabet, .omitPaddingCharacter]])
    func encodeIntoSpansMatchesEncodeToBytes(options: Base64.EncodingOptions) {
        let bytes = Array(UInt8(0)...UInt8(255))
        let expected = Base64.encodeToBytes(bytes: bytes, options: options)
        let capacity = Base64.encodedLength(bytesCount: bytes.count, options: options)

        // Exactly-sized buffer: also pins `encodedLength` against the encoder.
        var storage = [UInt8](repeating: 0, count: capacity)
        let written = bytes.withUnsafeBufferPointer { input -> Int in
            var output = storage.mutableSpan
            return Base64.encode(bytes: input.span, into: &output, options: options)
        }
        #expect(written == expected.count)
        #expect(storage == expected)

        let appended = [UInt8](capacity: capacity) { (output: inout OutputSpan<UInt8>) in
            bytes.withUnsafeBufferPointer { input in
                _ = Base64.encode(bytes: input.span, into: &output, options: options)
            }
        }
        #expect(appended == expected)
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test
    func encodeIntoSpansPreservesSurroundingBytes() {
        let prefix: [UInt8] = [UInt8(ascii: "x"), UInt8(ascii: "y")]
        let bytes: [UInt8] = [1, 2, 3, 4, 5]
        let expected = Base64.encodeToBytes(bytes: bytes)

        var written = 0
        let appended = [UInt8](capacity: prefix.count + expected.count) { (output: inout OutputSpan<UInt8>) in
            for byte in prefix { output.append(byte) }
            bytes.withUnsafeBufferPointer { input in
                written = Base64.encode(bytes: input.span, into: &output)
            }
        }
        #expect(written == expected.count)
        #expect(appended == prefix + expected)

        // MutableSpan must not write past the encoded length.
        var storage = [UInt8](repeating: 0xAA, count: expected.count + 16)
        let count = bytes.withUnsafeBufferPointer { input -> Int in
            var output = storage.mutableSpan
            return Base64.encode(bytes: input.span, into: &output)
        }
        #expect(Array(storage[..<count]) == expected)
        #expect(storage[count...].allSatisfy { $0 == 0xAA })
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test(arguments: [Base64.EncodingOptions(), .base64UrlAlphabet, .omitPaddingCharacter, [.base64UrlAlphabet, .omitPaddingCharacter]])
    func decodeIntoSpansMatchesDecode(options: Base64.EncodingOptions) throws {
        let expected = Array(UInt8(0)...UInt8(255))
        let encoded = Base64.encodeToBytes(bytes: expected, options: options)
        let decodingOptions = Base64.DecodingOptions(rawValue: options.rawValue)

        var storage = [UInt8](repeating: 0, count: Base64.decodedLength(bytesCount: encoded.count))
        let written = try encoded.withUnsafeBufferPointer { input -> Int in
            var output = storage.mutableSpan
            return try Base64.decode(bytes: input.span, into: &output, options: decodingOptions)
        }
        #expect(written == expected.count)
        #expect(Array(storage[..<written]) == expected)

        let appended = try [UInt8](capacity: Base64.decodedLength(bytesCount: encoded.count)) {
            (output: inout OutputSpan<UInt8>) in
            try encoded.withUnsafeBufferPointer { input in
                _ = try Base64.decode(bytes: input.span, into: &output, options: decodingOptions)
            }
        }
        #expect(appended == expected)
    }

    @available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    @Test
    func decodeIntoOutputSpanPreservesExistingPrefix() throws {
        let prefix: [UInt8] = [UInt8(ascii: "x"), UInt8(ascii: "y")]
        let expected: [UInt8] = [1, 2, 3, 4, 5]
        let encoded = Base64.encodeToBytes(bytes: expected)

        var written = 0
        let capacity = prefix.count + Base64.decodedLength(bytesCount: encoded.count)
        let appended = try [UInt8](capacity: capacity) { (output: inout OutputSpan<UInt8>) in
            for byte in prefix { output.append(byte) }
            try encoded.withUnsafeBufferPointer { input in
                written = try Base64.decode(bytes: input.span, into: &output, options: [])
            }
        }

        #expect(written == expected.count)
        #expect(appended == prefix + expected)
    }
}
