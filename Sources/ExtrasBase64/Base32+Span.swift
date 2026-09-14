extension String {
    /// Create a base32 encoded string from the bytes in `bytes`.
    @inlinable
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public init(base32Encoding bytes: Span<UInt8>, options: Base32.EncodingOptions = []) {
        self = Base32.encodeToString(bytes: bytes, options: options)
    }
}

// MARK: - Encoding -

extension Base32 {
    /// Write the base32 encoding of `bytes` to `output`.
    ///
    /// `output` must be at least `encodedLength(bytesCount:options:)` bytes long.
    ///
    /// - Returns: The number of bytes written to `output`.
    @available(macOS 10.14.4, *)
    @inlinable
    @_lifetime(output: copy output)
    public static func encode(
        bytes: Span<UInt8>,
        into output: inout MutableSpan<UInt8>,
        options: EncodingOptions = []
    ) -> Int {
        bytes.withUnsafeBufferPointer { input in
            output.withUnsafeMutableBufferPointer { output in
                Self._encode(from: input, into: output, options: options)
            }
        }
    }

    /// Append the base32 encoding of `bytes` to `output`.
    ///
    /// `output` must have at least `encodedLength(bytesCount:options:)` bytes of
    /// free capacity. Elements already present in `output` are preserved.
    ///
    /// - Returns: The number of bytes appended to `output`.
    @available(macOS 10.14.4, *)
    @inlinable
    @discardableResult
    @_lifetime(output: copy output)
    public static func encode(
        bytes: Span<UInt8>,
        into output: inout OutputSpan<UInt8>,
        options: EncodingOptions = []
    ) -> Int {
        bytes.withUnsafeBufferPointer { input in
            output.withUnsafeMutableBufferPointer { output, initializedCount in
                let free = UnsafeMutableBufferPointer(rebasing: output[initializedCount...])
                let written = Self._encode(from: input, into: free, options: options)
                initializedCount += written
                return written
            }
        }
    }

    /// Return the base32 encoding of `bytes` as ASCII characters.
    ///
    /// Use `encode(bytes:into:options:)` instead to avoid the allocation.
    @available(macOS 10.14.4, *)
    @inlinable
    public static func encodeToBytes(
        bytes: Span<UInt8>,
        options: EncodingOptions = []
    ) -> [UInt8] {
        let capacity = encodedLength(bytesCount: bytes.count, options: options)

        return bytes.withUnsafeBufferPointer { input in
            [UInt8](unsafeUninitializedCapacity: capacity) { buffer, length in
                length = Self._encode(from: input, into: buffer, options: options)
            }
        }
    }

    /// Return the base32 encoding of `bytes` as a string.
    ///
    /// Use `encode(bytes:into:options:)` instead to avoid the allocation.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    @inlinable
    public static func encodeToString(
        bytes: Span<UInt8>,
        options: EncodingOptions = []
    ) -> String {
        let capacity = encodedLength(bytesCount: bytes.count, options: options)

        return bytes.withUnsafeBufferPointer { input in
            String(unsafeUninitializedCapacity: capacity) { buffer in
                Self._encode(from: input, into: buffer, options: options)
            }
        }
    }
}

// MARK: - Decoding -

extension Base32 {
    /// Write the base32 decoding of `bytes` to `output`.
    ///
    /// `output` must be large enough to hold the decoded bytes.
    ///
    /// - Throws: A ``Base32/DecodingError`` if `bytes` is not valid base32.
    /// - Returns: The number of bytes written to `output`.
    @available(macOS 10.14.4, *)
    @inlinable
    @_lifetime(output: copy output)
    public static func decode(
        bytes: Span<UInt8>,
        into output: inout MutableSpan<UInt8>,
        options: DecodingOptions = []
    ) throws -> Int {
        guard bytes.count > 0 else {
            return 0
        }

        return try bytes.withUnsafeBufferPointer { input in
            try output.withUnsafeMutableBufferPointer { output in
                if options.contains(.allowNullCharacters) {
                    try Self._decode(from: input[...], into: output[...])
                } else {
                    try Self._strictDecode(from: input, into: output)
                }
            }
        }
    }

    /// Append the base32 decoding of `bytes` to `output`.
    ///
    /// `output` must have enough free capacity to hold the decoded bytes.
    /// Elements already present in `output` are preserved.
    ///
    /// - Throws: A ``Base32/DecodingError`` if `bytes` is not valid base32.
    /// - Returns: The number of bytes appended to `output`.
    @available(macOS 10.14.4, *)
    @inlinable
    @discardableResult
    @_lifetime(output: copy output)
    public static func decode(
        bytes: Span<UInt8>,
        into output: inout OutputSpan<UInt8>,
        options: DecodingOptions = []
    ) throws -> Int {
        guard bytes.count > 0 else {
            return 0
        }

        return try bytes.withUnsafeBufferPointer { input in
            try output.withUnsafeMutableBufferPointer { output, initializedCount in
                // Rebase for both paths so each returns a count relative to the free
                // region. `_decode` reports an index into whatever slice it is given,
                // while `_strictDecode` reports one relative to its buffer's start.
                let free = UnsafeMutableBufferPointer(rebasing: output[initializedCount...])
                let written: Int
                if options.contains(.allowNullCharacters) {
                    written = try Self._decode(from: input[...], into: free[...])
                } else {
                    written = try Self._strictDecode(from: input, into: free)
                }

                initializedCount += written
                return written
            }
        }
    }
}
