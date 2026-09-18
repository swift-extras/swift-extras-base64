extension String {
    /// Create a base64 encoded string from the bytes in `bytes`.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    @inlinable
    public init(base64Encoding bytes: Span<UInt8>, options: Base64.EncodingOptions = []) {
        self = Base64.encodeToString(bytes: bytes, options: options)
    }
}

// MARK: - Encoding -

extension Base64 {
    /// Write the base64 encoding of `bytes` to `output`.
    ///
    /// `output` must be at least `encodedLength(bytesCount:options:)` bytes long.
    ///
    /// - Returns: The number of bytes written to `output`.
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    @inlinable
    @_lifetime(output: copy output)
    public static func encode(
        bytes: Span<UInt8>,
        into output: inout MutableSpan<UInt8>,
        options: EncodingOptions = []
    ) -> Int {
        bytes.withUnsafeBufferPointer { input in
            output.withUnsafeMutableBufferPointer { output in
                Self._encodeChromium(input: input, buffer: output, options: options)
            }
        }
    }

    /// Append the base64 encoding of `bytes` to `output`.
    ///
    /// `output` must have at least `encodedLength(bytesCount:options:)` bytes of
    /// free capacity. Elements already present in `output` are preserved.
    ///
    /// - Returns: The number of bytes appended to `output`.
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    @inlinable
    @discardableResult
    @_lifetime(output: copy output)
    public static func encode(
        bytes: Span<UInt8>,
        into output: inout OutputSpan<UInt8>,
        options: EncodingOptions = []
    ) -> Int {
        var written = 0
        bytes.withUnsafeBufferPointer { input in
            output.withUnsafeMutableBufferPointer { buffer, initializedCount in
                let free = UnsafeMutableBufferPointer(rebasing: buffer[initializedCount...])
                written = Self._encodeChromium(input: input, buffer: free, options: options)
                initializedCount += written
            }
        }
        return written
    }

    /// Return the base64 encoding of `bytes` as ASCII characters.
    ///
    /// Use `encode(bytes:into:options:)` instead to avoid the allocation.
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    @inlinable
    public static func encodeToBytes(bytes: Span<UInt8>, options: EncodingOptions = []) -> [UInt8] {
        let newCapacity = encodedLength(bytesCount: bytes.count, options: options)

        return bytes.withUnsafeBufferPointer { input -> [UInt8] in
            [UInt8](unsafeUninitializedCapacity: newCapacity) { buffer, length in
                length = Self._encodeChromium(input: input, buffer: buffer, options: options)
            }
        }
    }

    /// Return the base64 encoding of `bytes` as a string.
    ///
    /// Use `encode(bytes:into:options:)` instead to avoid the allocation.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    @inlinable
    public static func encodeToString(bytes: Span<UInt8>, options: EncodingOptions = []) -> String {
        let newCapacity = encodedLength(bytesCount: bytes.count, options: options)

        return bytes.withUnsafeBufferPointer { input -> String in
            String(unsafeUninitializedCapacity: newCapacity) { buffer -> Int in
                Self._encodeChromium(input: input, buffer: buffer, options: options)
            }
        }
    }
}

// MARK: - Decoding -

extension Base64 {
    /// Write the base64 decoding of `bytes` to `output`.
    ///
    /// `output` must be at least `decodedLength(bytesCount:)` bytes long.
    ///
    /// - Throws: A ``Base64/DecodingError`` if `bytes` is not valid base64.
    /// - Returns: The number of bytes written to `output`.
    @inlinable
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
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
                try Self._decodeChromium(from: input, into: output, options: options)
            }
        }
    }

    /// Append the base64 decoding of `bytes` to `output`.
    ///
    /// `output` must have at least `decodedLength(bytesCount:)` bytes of free
    /// capacity. Elements already present in `output` are preserved.
    ///
    /// - Throws: A ``Base64/DecodingError`` if `bytes` is not valid base64.
    /// - Returns: The number of bytes appended to `output`.
    @inlinable
    @discardableResult
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
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
            try output.withUnsafeMutableBufferPointer { buffer, initializedCount in
                let free = UnsafeMutableBufferPointer(rebasing: buffer[initializedCount...])
                let written = try Self._decodeChromium(from: input, into: free, options: options)
                initializedCount += written
                return written
            }
        }
    }

    /// Return the bytes that `bytes` encodes.
    ///
    /// Use `decode(bytes:into:options:)` instead to avoid the allocation.
    ///
    /// - Throws: A ``Base64/DecodingError`` if `bytes` is not valid base64.
    @inlinable
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public static func decode(bytes: Span<UInt8>, options: DecodingOptions = []) throws -> [UInt8] {
        guard bytes.count > 0 else {
            return []
        }

        return try bytes.withUnsafeBufferPointer { input -> [UInt8] in
            let outputLength = decodedLength(bytesCount: input.count)

            return try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                length = try Self._decodeChromium(from: input, into: output, options: options)
            }
        }
    }
}
