/// String extensions
extension String {
    /// Create a base32 encoded string from a buffer
    @inlinable
    public init(base32Encoding bytes: some Collection<UInt8>, options: Base32.EncodingOptions = []) {
        self = Base32.encodeToString(bytes: bytes, options: options)
    }

    /// Decode base32 encoded string
    @inlinable
    public func base32decoded(options: Base32.DecodingOptions = []) throws -> [UInt8] {
        try Base32.decode(string: self, options: options)
    }
}

/// Base32 encoding and decoding support
public enum Base32 {
    /// Encoding options
    public struct EncodingOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let omitPaddingCharacter = EncodingOptions(rawValue: UInt(1 << 0))
    }

    /// Decoding options
    public struct DecodingOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let allowNullCharacters = DecodingOptions(rawValue: UInt(1 << 0))
    }

    public struct DecodingError: Swift.Error, Equatable, Sendable {
        enum _Internal {
            case invalidCharacter
        }

        fileprivate let value: _Internal
        init(_ value: _Internal) {
            self.value = value
        }

        public static var invalidCharacter: Self { .init(.invalidCharacter) }
    }

    @inlinable
    public static func encodedLength(bytesCount count: Int, options: EncodingOptions = []) -> Int {
        let (quotient, remainder) = count.quotientAndRemainder(dividingBy: 5)
        if options.contains(.omitPaddingCharacter) {
            return quotient * 8 + (remainder == 0 ? 0 : (remainder * 8 + 4) / 5)
        }
        return (quotient + (remainder == 0 ? 0 : 1)) * 8
    }

    /// Base32 Encode a buffer to an array of bytes
    @inlinable
    public static func encodeToBytes(
        bytes: some Collection<UInt8>,
        options: EncodingOptions = []
    ) -> [UInt8] {
        let capacity = encodedLength(bytesCount: bytes.count, options: options)

        let result = bytes.withContiguousStorageIfAvailable { input in
            unsafe [UInt8](unsafeUninitializedCapacity: capacity) { buffer, length in
                length = unsafe Self._encode(from: input, into: buffer, options: options)
            }
        }
        if let result {
            return result
        }

        return self.encodeToBytes(bytes: Array(bytes), options: options)
    }

    /// Base32 Encode a buffer to a string
    @inlinable
    public static func encodeToString(
        bytes: some Collection<UInt8>,
        options: EncodingOptions = []
    ) -> String {
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            let capacity = encodedLength(bytesCount: bytes.count, options: options)

            let result = bytes.withContiguousStorageIfAvailable { input in
                unsafe String(unsafeUninitializedCapacity: capacity) { buffer in
                    unsafe Self._encode(from: input, into: buffer, options: options)
                }
            }
            if let result {
                return result
            }

            return self.encodeToString(bytes: Array(bytes), options: options)
        } else {
            let encoded: [UInt8] = self.encodeToBytes(bytes: bytes, options: options)
            return String(decoding: encoded, as: Unicode.UTF8.self)
        }
    }

    @inlinable
    public static func decodedLength(bytesCount count: Int) -> Int {
        ((count + 7) / 8) * 5
    }

    /// Base32 decode string
    @inlinable
    public static func decode(
        string encoded: String,
        options: DecodingOptions = []
    ) throws -> [UInt8] {
        let decoded = try unsafe encoded.utf8.withContiguousStorageIfAvailable { characterPointer -> [UInt8] in
            guard characterPointer.count > 0 else {
                return []
            }

            let capacity = decodedLength(bytesCount: encoded.utf8.count)

            return unsafe try characterPointer.withMemoryRebound(to: UInt8.self) { input -> [UInt8] in
                unsafe try [UInt8](unsafeUninitializedCapacity: capacity) { output, length in
                    if options.contains(.allowNullCharacters) {
                        length = unsafe try Self._decode(from: input[...], into: output[...])
                    } else {
                        length = unsafe try Self._strictDecode(from: input, into: output)
                    }
                }
            }
        }

        if let decoded {
            return decoded
        }

        var encoded = encoded
        encoded.makeContiguousUTF8()
        return try Self.decode(string: encoded, options: options)
    }

    /// Base32 decode a buffer to an array of UInt8
    @inlinable
    public static func decode(
        bytes: some Collection<UInt8>,
        options: DecodingOptions = []
    ) throws -> [UInt8] {
        guard bytes.count > 0 else {
            return []
        }

        let decoded = try bytes.withContiguousStorageIfAvailable { input -> [UInt8] in
            let outputLength = decodedLength(bytesCount: input.count)

            return unsafe try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                if options.contains(.allowNullCharacters) {
                    length = unsafe try Self._decode(from: input[...], into: output[...])
                } else {
                    length = unsafe try Self._strictDecode(from: input, into: output)
                }
            }
        }

        if let decoded {
            return decoded
        }

        return try self.decode(bytes: Array(bytes), options: options)
    }
}

extension Base32 {
    @usableFromInline
    static let decodeTable: [UInt32] = [
        /* 00 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 08 */ 0x80, 0x40, 0x40, 0x80, 0x80, 0x40, 0x80, 0x80,
        /* 10 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 18 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 20 */ 0x40, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 28 */ 0x80, 0x80, 0x80, 0x40, 0x80, 0x80, 0x80, 0x80,
        /* 30 */ 0x80, 0x80, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
        /* 38 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0xC0, 0x80, 0x80,
        /* 40 */ 0x80, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        /* 48 */ 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        /* 50 */ 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        /* 58 */ 0x17, 0x18, 0x19, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 60 */ 0x80, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        /* 68 */ 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        /* 60 */ 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        /* 68 */ 0x17, 0x18, 0x19, 0x80, 0x80, 0x80, 0x80, 0x80,

        /* 80 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 88 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 90 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 98 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* A0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* A8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* B0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* B8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* C0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* C8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* D0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* D8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* E0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* E8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* F0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* F8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
    ]

    @usableFromInline
    static let strictDecodeTable: [UInt8] = [
        /* 00 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 08 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 10 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 18 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 20 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 28 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 30 */ 0x80, 0x80, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
        /* 38 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0xC0, 0x80, 0x80,
        /* 40 */ 0x80, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        /* 48 */ 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        /* 50 */ 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        /* 58 */ 0x17, 0x18, 0x19, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 60 */ 0x80, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        /* 68 */ 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
        /* 60 */ 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16,
        /* 68 */ 0x17, 0x18, 0x19, 0x80, 0x80, 0x80, 0x80, 0x80,

        /* 80 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 88 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 90 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* 98 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* A0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* A8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* B0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* B8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* C0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* C8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* D0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* D8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* E0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* E8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* F0 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
        /* F8 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
    ]

    @usableFromInline
    static let encodeTable: [UInt8] = [
        /* 00 */ 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
        /* 08 */ 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
        /* 10 */ 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
        /* 18 */ 0x59, 0x5A, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    ]

    /// Decode Base32 assuming there are no null characters
    @inlinable
    static func _strictDecode(from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
        guard input.count != 0 else { return 0 }

        var outputIndex = 0
        // work out how many blocks can go through the fast path. Last block
        // should be passed to the slow path
        let inputMinusLastBlock = (input.count - 1) & ~0x7
        var i = 0
        while i < inputMinusLastBlock {
            let v1 = unsafe self.strictDecodeTable[Int(input[i])]
            let v2 = unsafe self.strictDecodeTable[Int(input[i + 1])]
            let v3 = unsafe self.strictDecodeTable[Int(input[i + 2])]
            let v4 = unsafe self.strictDecodeTable[Int(input[i + 3])]
            let v5 = unsafe self.strictDecodeTable[Int(input[i + 4])]
            let v6 = unsafe self.strictDecodeTable[Int(input[i + 5])]
            let v7 = unsafe self.strictDecodeTable[Int(input[i + 6])]
            let v8 = unsafe self.strictDecodeTable[Int(input[i + 7])]
            let vCombined = v1 | v2 | v3 | v4 | v5 | v6 | v7 | v8
            if (vCombined & ~0x1F) != 0 {
                throw DecodingError.invalidCharacter
            }
            i += 8
            unsafe output[outputIndex] = (v1 << 3) | (v2 >> 2)
            unsafe output[outputIndex + 1] = (v2 << 6) | (v3 << 1) | (v4 >> 4)
            unsafe output[outputIndex + 2] = (v4 << 4) | (v5 >> 1)
            unsafe output[outputIndex + 3] = (v5 << 7) | (v6 << 2) | (v7 >> 3)
            unsafe output[outputIndex + 4] = (v7 << 5) | v8
            outputIndex += 5
        }

        return unsafe try self._decode(from: input[i...], into: output[outputIndex...])
    }

    /// Decode Base32 with the possibility of null characters or padding
    @inlinable
    static func _decode(
        from input: UnsafeBufferPointer<UInt8>.SubSequence,
        into output: UnsafeMutableBufferPointer<UInt8>.SubSequence
    ) throws -> Int {
        guard unsafe input.count != 0 else { return unsafe output.startIndex }
        var output = unsafe output
        var bitsLeft = 0
        var buffer: UInt32 = 0
        var outputIndex = unsafe output.startIndex
        var i = unsafe input.startIndex
        loop: while unsafe i < input.endIndex {
            let index = unsafe Int(input[i])
            i += 1
            let v = self.decodeTable[index]
            switch v {
            case 0x80:
                throw DecodingError.invalidCharacter
            case 0x40:
                continue
            case 0xC0:
                break loop
            default:
                buffer <<= 5
                buffer |= v
                bitsLeft += 5
                if bitsLeft >= 8 {
                    let result = (buffer >> (bitsLeft - 8))
                    unsafe output[outputIndex] = UInt8(result & 0xFF)
                    outputIndex += 1
                    bitsLeft -= 8
                }
            }
        }
        // Any characters left should be padding
        while unsafe i < input.endIndex {
            let index = unsafe Int(input[i])
            guard self.decodeTable[index] == 0xC0 else { throw DecodingError.invalidCharacter }
            i += 1
        }
        return outputIndex
    }

    @inlinable
    static func _encode(
        from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>, options: EncodingOptions
    ) -> Int {
        guard input.count != 0 else { return 0 }

        precondition(
            output.count >= Self.encodedLength(bytesCount: input.count, options: options),
            "Expected the output buffer to be at least as long as the encoded length"
        )

        var outputIndex = 0
        let inputMinusLastBlock = (input.count / 5) * 5
        var i = 0
        while i < inputMinusLastBlock {
            let v1 = unsafe Int(input[i])
            let v2 = unsafe Int(input[i + 1])
            let v3 = unsafe Int(input[i + 2])
            let v4 = unsafe Int(input[i + 3])
            let v5 = unsafe Int(input[i + 4])
            i += 5
            unsafe output[outputIndex] = self.encodeTable[(v1 & 0xF8) >> 3]
            unsafe output[outputIndex + 1] = self.encodeTable[(v1 & 0x7) << 2 + (v2 & 0xC0) >> 6]
            unsafe output[outputIndex + 2] = self.encodeTable[(v2 & 0x3E) >> 1]
            unsafe output[outputIndex + 3] = self.encodeTable[(v2 & 0x1) << 4 + (v3 & 0xF0) >> 4]
            unsafe output[outputIndex + 4] = self.encodeTable[(v3 & 0xF) << 1 + (v4 & 0x80) >> 7]
            unsafe output[outputIndex + 5] = self.encodeTable[(v4 & 0x7C) >> 2]
            unsafe output[outputIndex + 6] = self.encodeTable[(v4 & 0x3) << 3 + (v5 & 0xE0) >> 5]
            unsafe output[outputIndex + 7] = self.encodeTable[v5 & 0x1F]
            outputIndex += 8
        }
        let remainingBytes = input.count - inputMinusLastBlock
        var v1 = 0
        var v2 = 0
        var v3 = 0
        var v4 = 0
        switch remainingBytes {
        case 0:
            return outputIndex
        case 4:
            v4 = unsafe Int(input[i + 3])
            unsafe output[outputIndex + 6] = self.encodeTable[(v4 & 0x3) << 3]
            unsafe output[outputIndex + 5] = self.encodeTable[(v4 & 0x7C) >> 2]
            fallthrough
        case 3:
            v3 = unsafe Int(input[i + 2])
            unsafe output[outputIndex + 4] = self.encodeTable[(v3 & 0xF) << 1 + (v4 & 0x80) >> 7]
            fallthrough
        case 2:
            v2 = unsafe Int(input[i + 1])
            unsafe output[outputIndex + 3] = self.encodeTable[(v2 & 0x1) << 4 + (v3 & 0xF0) >> 4]
            unsafe output[outputIndex + 2] = self.encodeTable[(v2 & 0x3E) >> 1]
            fallthrough
        case 1:
            v1 = unsafe Int(input[i])
            unsafe output[outputIndex + 1] = self.encodeTable[(v1 & 0x7) << 2 + (v2 & 0xC0) >> 6]
            unsafe output[outputIndex] = self.encodeTable[(v1 & 0xF8) >> 3]
        default:
            preconditionFailure("Shouldn't get here")
        }
        outputIndex += (remainingBytes * 8 + 4) / 5
        if !options.contains(.omitPaddingCharacter) {
            let fullOutputSize = ((outputIndex + 7) / 8) * 8
            while outputIndex < fullOutputSize {
                unsafe output[outputIndex] = UInt8(ascii: "=")
                outputIndex += 1
            }
        }
        return outputIndex
    }
}
