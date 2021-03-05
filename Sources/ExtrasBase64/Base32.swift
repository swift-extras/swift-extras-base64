
/// String extensions
extension String {
    public init<Buffer: Collection>(base32Encoding bytes: Buffer) where Buffer.Element == UInt8 {
        self = Base32.encodeString(bytes: bytes)
    }

    public func base32decoded() throws -> [UInt8] {
        try Base32.decode(string: self)
    }
}

public enum Base32 {
    public enum DecodingError: Swift.Error, Equatable {
        case invalidCharacter(UInt8)
    }
    
    /// Base32 Encode a buffer to an array of bytes
    public static func encodeBytes<Buffer: Collection>(bytes: Buffer) -> [UInt8] where Buffer.Element == UInt8 {
        let capacity = (bytes.count * 8 + 4) / 5

        let result = bytes.withContiguousStorageIfAvailable { input -> [UInt8] in
            return [UInt8](unsafeUninitializedCapacity: capacity) { buffer, length in
                length = Self._encode(from: input, into: buffer)
            }
        }
        if let result = result {
            return result
        }

        return self.encodeBytes(bytes: Array(bytes))
    }

    /// Base32 Encode a buffer to a string
    public static func encodeString<Buffer: Collection>(bytes: Buffer) -> String where Buffer.Element == UInt8 {
        let capacity = (bytes.count * 8 + 4) / 5

        if #available(macOS 11.0, *) {
            let result = bytes.withContiguousStorageIfAvailable { input in
                String(unsafeUninitializedCapacity: capacity) { buffer -> Int in
                    return Self._encode(from: input, into: buffer)
                }
            }
            if let result = result {
                return result
            }

            return self.encodeString(bytes: Array(bytes))
        } else {
            let bytes: [UInt8] = self.encodeBytes(bytes: bytes)
            return String(decoding: bytes, as: Unicode.UTF8.self)
        }
    }
    
    /// Base32 decode string
    public static func decode(string encoded: String) throws -> [UInt8] {
        let decoded = try encoded.utf8.withContiguousStorageIfAvailable { (characterPointer) -> [UInt8] in
            guard characterPointer.count > 0 else {
                return []
            }

            let capacity = (encoded.utf8.count * 5 + 4) / 8

            return try characterPointer.withMemoryRebound(to: UInt8.self) { (input) -> [UInt8] in
                try [UInt8](unsafeUninitializedCapacity: capacity) { output, length in
                    length = try Self._decode(from: input, into: output)
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

    public static func decode<Buffer: Collection>(bytes: Buffer) throws -> [UInt8] where Buffer.Element == UInt8 {
        guard bytes.count > 0 else {
            return []
        }

        let decoded = try bytes.withContiguousStorageIfAvailable { (input) -> [UInt8] in
            let outputLength = ((input.count + 3) / 4) * 3

            return try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                length = try Self._decode(from: input, into: output)
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
        /* 38 */ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
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

    private static func _decode(from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
        guard input.count != 0 else { return 0 }
        
        return try self.decodeTable.withUnsafeBufferPointer { decodeTable in
            var bitsLeft: Int = 0
            var buffer: UInt32 = 0
            var outputIndex = 0
            for i in 0..<input.count {
                let index = Int(input[i])
                let v = decodeTable[index]
                // check for unexpected character
                guard v != 0x80 else { throw DecodingError.invalidCharacter(input[i]) }
                // check for ignorable character
                guard v != 0x40 else { continue }

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
            return outputIndex
        }
    }

    private static func _encode(from input: UnsafeBufferPointer<UInt8>, into output: UnsafeMutableBufferPointer<UInt8>) -> Int {
        guard input.count != 0 else { return 0 }
        
        return self.encodeTable.withUnsafeBufferPointer { encodeTable in
            var outputIndex = 0
            var i = 1
            var bitsLeft = 8
            var buffer = Int(input[0])
            while i < input.count {
                if bitsLeft < 5 {
                    buffer <<= 8
                    buffer |= Int(input[i])
                    i += 1
                    bitsLeft += 8
                }
                let unmaskedIndex = (buffer >> (bitsLeft - 5))
                let index = 0x1F & unmaskedIndex
                bitsLeft -= 5
                output[outputIndex] = encodeTable[index]
                outputIndex += 1
            }

            while bitsLeft > 0 {
                if bitsLeft < 5 {
                    let pad = 5 - bitsLeft
                    buffer <<= pad
                    bitsLeft += pad
                }
                let unmaskedIndex = (buffer >> (bitsLeft - 5))
                let index = 0x1F & unmaskedIndex
                bitsLeft -= 5
                output[outputIndex] = encodeTable[index]
                outputIndex += 1
            }
            return outputIndex
        }
    }
}
