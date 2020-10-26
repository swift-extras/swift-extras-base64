
public enum Base64 {
    public struct EncodingOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let base64UrlAlphabet = EncodingOptions(rawValue: UInt(1 << 0))
        public static let omitPaddingCharacter = EncodingOptions(rawValue: UInt(1 << 1))
    }

    public struct DecodingOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let base64UrlAlphabet = DecodingOptions(rawValue: UInt(1 << 0))
        public static let omitPaddingCharacter = DecodingOptions(rawValue: UInt(1 << 1))
    }
}

//// MARK: - Extensions -

// extension String {
//    @inlinable
//    public init<Buffer: Collection>(base64Encoding bytes: Buffer, options: Base64.EncodingOptions = [])
//        where Buffer.Element == UInt8 {
//        self = Base64.encode(bytes: bytes, options: options)
//    }
//
//    public func base64decoded(options: Base64.DecodingOptions = []) throws -> [UInt8] {
//        // In Base64, 3 bytes become 4 output characters, and we pad to the nearest multiple
//        // of four.
//        return try Base64.decode(encoded: self, options: options)
//    }
// }
