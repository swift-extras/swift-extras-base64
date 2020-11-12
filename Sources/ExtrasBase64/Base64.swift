
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

public extension String {
    @inlinable
    init<Buffer: Collection>(base64Encoding bytes: Buffer, options: Base64.EncodingOptions = [])
        where Buffer.Element == UInt8
    {
        self = Base64.encodeString(bytes: bytes, options: options)
    }

    func base64decoded(options: Base64.DecodingOptions = []) throws -> [UInt8] {
        try Base64.decode(string: self, options: options)
    }
}
