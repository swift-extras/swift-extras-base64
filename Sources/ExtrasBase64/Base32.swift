
/// String extensions
public extension String {
    /// Create a base32 encoded string from a buffer
    init<Buffer: Collection>(base32Encoding bytes: Buffer, options: Base32.EncodingOptions = []) where Buffer.Element == UInt8 {
        self = Base32.encodeToString(bytes: bytes, options: options)
    }

    /// Decode base32 encoded strin
    func base32decoded() throws -> [UInt8] {
        try Base32.decode(string: self)
    }
}

/// Base32 encoding and decoding support
public enum Base32 {
    /// Encoding options
    public struct EncodingOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let omitPaddingCharacter = EncodingOptions(rawValue: UInt(1 << 0))
    }

    /// Decoding options
    public struct DecodingOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let allowNullCharacters = DecodingOptions(rawValue: UInt(1 << 0))
    }

    public enum DecodingError: Swift.Error, Equatable {
        case invalidCharacter
    }

    /// Base32 Encode a buffer to an array of bytes
    public static func encodeToBytes<Buffer: Collection>(
        bytes: Buffer,
        options: EncodingOptions = []
    ) -> [UInt8] where Buffer.Element == UInt8 {
        let capacity = ((bytes.count + 4) / 5) * 8

        let result = bytes.withContiguousStorageIfAvailable { input -> [UInt8] in
            [UInt8](unsafeUninitializedCapacity: capacity) { buffer, length in
                length = Self._encode(from: input, into: buffer, options: options)
            }
        }
        if let result = result {
            return result
        }

        return self.encodeToBytes(bytes: Array(bytes))
    }

    /// Base32 Encode a buffer to a string
    public static func encodeToString<Buffer: Collection>(
        bytes: Buffer,
        options: EncodingOptions = []
    ) -> String where Buffer.Element == UInt8 {
        let capacity = ((bytes.count + 4) / 5) * 8

        if #available(OSX 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            let result = bytes.withContiguousStorageIfAvailable { input in
                String(unsafeUninitializedCapacity: capacity) { buffer -> Int in
                    Self._encode(from: input, into: buffer, options: options)
                }
            }
            if let result = result {
                return result
            }

            return self.encodeToString(bytes: Array(bytes))
        } else {
            let bytes: [UInt8] = self.encodeToBytes(bytes: bytes)
            return String(decoding: bytes, as: Unicode.UTF8.self)
        }
    }

    /// Base32 decode string
    public static func decode(
        string encoded: String,
        options: DecodingOptions = []
    ) throws -> [UInt8] {
        let decoded = try encoded.utf8.withContiguousStorageIfAvailable { characterPointer -> [UInt8] in
            guard characterPointer.count > 0 else {
                return []
            }

            let capacity = (encoded.utf8.count * 5 + 7) / 8

            return try characterPointer.withMemoryRebound(to: UInt8.self) { input -> [UInt8] in
                try [UInt8](unsafeUninitializedCapacity: capacity) { output, length in
                    if options.contains(.allowNullCharacters) {
                        length = try Self._decode(from: input[...], into: output[...])
                    } else {
                        length = try Self._strictDecode(from: input, into: output)
                    }
                }
            }
        }

        if let decoded = decoded {
            return decoded
        }

        var encoded = encoded
        encoded.makeContiguousUTF8()
        return try Self.decode(string: encoded)
    }

    /// Base32 decode a buffer to an array of UInt8
    public static func decode<Buffer: Collection>(
        bytes: Buffer,
        options: DecodingOptions = []
    ) throws -> [UInt8] where Buffer.Element == UInt8 {
        guard bytes.count > 0 else {
            return []
        }

        let decoded = try bytes.withContiguousStorageIfAvailable { input -> [UInt8] in
            let outputLength = ((input.count + 7) / 8) * 5

            return try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                if options.contains(.allowNullCharacters) {
                    length = try Self._decode(from: input[...], into: output[...])
                } else {
                    length = try Self._strictDecode(from: input, into: output)
                }
            }
        }

        if decoded != nil {
            return decoded!
        }

        return try self.decode(bytes: Array(bytes))
    }
}

extension Base32 {
    private static let decodeTable: [UInt32] = [
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

    private static let strictDecodeTable: [UInt8] = [
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

    private static let encodeTable: [UInt8] = [
        /* 00 */ 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
        /* 08 */ 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
        /* 10 */ 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
        /* 18 */ 0x59, 0x5A, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    ]

    /// Decode Base32 assuming there are no null characters
    private static func _strictDecode(from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
        guard input.count != 0 else { return 0 }

        var outputIndex = 0
        // work out how many blocks can go through the fast path. Last block
        // should be passed to the slow path
        let inputMinusLastBlock = (input.count - 1) & ~0x7
        var i = 0
        while i < inputMinusLastBlock {
            let v1 = self.strictDecodeTable[Int(input[i])]
            let v2 = self.strictDecodeTable[Int(input[i + 1])]
            let v3 = self.strictDecodeTable[Int(input[i + 2])]
            let v4 = self.strictDecodeTable[Int(input[i + 3])]
            let v5 = self.strictDecodeTable[Int(input[i + 4])]
            let v6 = self.strictDecodeTable[Int(input[i + 5])]
            let v7 = self.strictDecodeTable[Int(input[i + 6])]
            let v8 = self.strictDecodeTable[Int(input[i + 7])]
            let vCombined = v1 | v2 | v3 | v4 | v5 | v6 | v7 | v8
            if (vCombined & ~0x1F) != 0 {
                throw DecodingError.invalidCharacter
            }
            i += 8
            output[outputIndex] = (v1 << 3) | (v2 >> 2)
            output[outputIndex + 1] = (v2 << 6) | (v3 << 1) | (v4 >> 4)
            output[outputIndex + 2] = (v4 << 4) | (v5 >> 1)
            output[outputIndex + 3] = (v5 << 7) | (v6 << 2) | (v7 >> 3)
            output[outputIndex + 4] = (v7 << 5) | v8
            outputIndex += 5
        }

        return try self._decode(from: input[i...], into: output[outputIndex...])
    }

    /// Decode Base32 with the possibility of null characters or padding
    private static func _decode(from input: UnsafeBufferPointer<UInt8>.SubSequence, into output: UnsafeMutableBufferPointer<UInt8>.SubSequence) throws -> Int {
        guard input.count != 0 else { return output.startIndex }
        var output = output
        var bitsLeft = 0
        var buffer: UInt32 = 0
        var outputIndex = output.startIndex
        var i = input.startIndex
        loop: while i < input.endIndex {
            let index = Int(input[i])
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
                    output[outputIndex] = UInt8(result & 0xFF)
                    outputIndex += 1
                    bitsLeft -= 8
                }
            }
        }
        // Any characters left should be padding
        while i < input.endIndex {
            let index = Int(input[i])
            guard self.decodeTable[index] == 0xC0 else { throw DecodingError.invalidCharacter }
            i += 1
        }
        return outputIndex
    }

    private static func _encode(from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>, options: EncodingOptions) -> Int {
        guard input.count != 0 else { return 0 }

        var outputIndex = 0
        let inputMinusLastBlock = (input.count / 5) * 5
        var i = 0
        while i < inputMinusLastBlock {
            let v1 = Int(input[i])
            let v2 = Int(input[i + 1])
            let v3 = Int(input[i + 2])
            let v4 = Int(input[i + 3])
            let v5 = Int(input[i + 4])
            i += 5
            output[outputIndex] = self.encodeTable[(v1 & 0xF8) >> 3]
            output[outputIndex + 1] = self.encodeTable[(v1 & 0x7) << 2 + (v2 & 0xC0) >> 6]
            output[outputIndex + 2] = self.encodeTable[(v2 & 0x3E) >> 1]
            output[outputIndex + 3] = self.encodeTable[(v2 & 0x1) << 4 + (v3 & 0xF0) >> 4]
            output[outputIndex + 4] = self.encodeTable[(v3 & 0xF) << 1 + (v4 & 0x80) >> 7]
            output[outputIndex + 5] = self.encodeTable[(v4 & 0x7C) >> 2]
            output[outputIndex + 6] = self.encodeTable[(v4 & 0x3) << 3 + (v5 & 0xE0) >> 5]
            output[outputIndex + 7] = self.encodeTable[v5 & 0x1F]
            outputIndex += 8
        }
        let remainingBytes = input.count - inputMinusLastBlock
        var v1 = 0, v2 = 0, v3 = 0, v4 = 0
        switch remainingBytes {
        case 0:
            return outputIndex
        case 4:
            v4 = Int(input[i + 3])
            output[outputIndex + 6] = self.encodeTable[(v4 & 0x3) << 3]
            output[outputIndex + 5] = self.encodeTable[(v4 & 0x7C) >> 2]
            fallthrough
        case 3:
            v3 = Int(input[i + 2])
            output[outputIndex + 4] = self.encodeTable[(v3 & 0xF) << 1 + (v4 & 0x80) >> 7]
            fallthrough
        case 2:
            v2 = Int(input[i + 1])
            output[outputIndex + 3] = self.encodeTable[(v2 & 0x1) << 4 + (v3 & 0xF0) >> 4]
            output[outputIndex + 2] = self.encodeTable[(v2 & 0x3E) >> 1]
            fallthrough
        case 1:
            v1 = Int(input[i])
            output[outputIndex + 1] = self.encodeTable[(v1 & 0x7) << 2 + (v2 & 0xC0) >> 6]
            output[outputIndex] = self.encodeTable[(v1 & 0xF8) >> 3]
        default:
            preconditionFailure("Shouldn't get here")
        }
        outputIndex += (remainingBytes * 8 + 4) / 5
        if !options.contains(.omitPaddingCharacter) {
            let fullOutputSize = ((outputIndex + 7) / 8) * 8
            while outputIndex < fullOutputSize {
                output[outputIndex] = UInt8(ascii: "=")
                outputIndex += 1
            }
        }
        return outputIndex
    }
}
