// This base64 implementation is heavily inspired by:

// https://github.com/lemire/fastbase64/blob/master/src/chromiumbase64.c
/*
 Copyright (c) 2015-2016, Wojciech Muła, Alfred Klomp,  Daniel Lemire
 (Unless otherwise stated in the source code)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// https://github.com/client9/stringencoders/blob/master/src/modp_b64.c
/*
 The MIT License (MIT)

 Copyright (c) 2016 Nick Galbreath

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// MARK: - Extensions -

extension String {
    @inlinable
    public init(base64Encoding bytes: some Collection<UInt8>, options: Base64.EncodingOptions = []) {
        self = Base64.encodeToString(bytes: bytes, options: options)
    }

    @inlinable
    public func base64decoded(options: Base64.DecodingOptions = []) throws -> [UInt8] {
        try Base64.decode(string: self, options: options)
    }
}

public enum Base64 {}

// MARK: - Encoding -

extension Base64 {
    public struct EncodingOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let base64UrlAlphabet = EncodingOptions(rawValue: UInt(1 << 0))
        public static let omitPaddingCharacter = EncodingOptions(rawValue: UInt(1 << 1))
    }

    @inlinable
    public static func encodedLength(bytesCount count: Int, options: EncodingOptions = []) -> Int {
        let (quotient, remainder) = count.quotientAndRemainder(dividingBy: 3)
        if options.contains(.omitPaddingCharacter) {
            return quotient * 4 + (remainder == 0 ? 0 : remainder + 1)
        }
        return (quotient + (remainder == 0 ? 0 : 1)) * 4
    }

    @inlinable
    public static func encodeToBytes(bytes: some Collection<UInt8>, options: EncodingOptions = []) -> [UInt8] {
        let newCapacity = encodedLength(bytesCount: bytes.count, options: options)

        if let result = bytes.withContiguousStorageIfAvailable({ input -> [UInt8] in
            [UInt8](unsafeUninitializedCapacity: newCapacity) { buffer, length in
                length = Self._encodeChromium(input: input, buffer: buffer, options: options)
            }
        }) {
            return result
        }

        return self.encodeToBytes(bytes: Array(bytes), options: options)
    }

    @inlinable
    public static func encodeToString(bytes: some Collection<UInt8>, options: EncodingOptions = []) -> String {
        let newCapacity = encodedLength(bytesCount: bytes.count, options: options)

        if let result = bytes.withContiguousStorageIfAvailable({ input -> String in
            String(unsafeUninitializedCapacity: newCapacity) { buffer -> Int in
                Self._encodeChromium(input: input, buffer: buffer, options: options)
            }
        }) {
            return result
        }

        return self.encodeToString(bytes: Array(bytes), options: options)
    }

    @inlinable
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
    @inlinable
    @discardableResult
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

    @inlinable
    @discardableResult
    static func _encodeChromium(
        input: UnsafeBufferPointer<UInt8>,
        buffer: UnsafeMutableBufferPointer<UInt8>,
        options: EncodingOptions
    ) -> Int {
        let omitPaddingCharacter = options.contains(.omitPaddingCharacter)

        precondition(
            buffer.count >= Self.encodedLength(bytesCount: input.count, options: options),
            "Expected the output buffer to be at least as long as the encoded length"
        )

        return Self.withUnsafeEncodingTablesAsBufferPointers(options: options) { e0, e1 in
            let to = input.count / 3 * 3
            var outIndex = 0
            for index in stride(from: 0, to: to, by: 3) {
                let i1 = input[index]
                let i2 = input[index + 1]
                let i3 = input[index + 2]
                buffer[outIndex] = e0[Int(i1)]
                buffer[outIndex + 1] = e1[Int(((i1 & 0x03) << 4) | ((i2 >> 4) & 0x0F))]
                buffer[outIndex + 2] = e1[Int(((i2 & 0x0F) << 2) | ((i3 >> 6) & 0x03))]
                buffer[outIndex + 3] = e1[Int(i3)]
                outIndex += 4
            }

            if to < input.count {
                let index = to

                let i1 = input[index]
                let i2 = index + 1 < input.count ? input[index + 1] : nil
                let i3 = index + 2 < input.count ? input[index + 2] : nil

                buffer[outIndex] = e0[Int(i1)]

                if let i2 = i2, let i3 = i3 {
                    buffer[outIndex + 1] = e1[Int(((i1 & 0x03) << 4) | ((i2 >> 4) & 0x0F))]
                    buffer[outIndex + 2] = e1[Int(((i2 & 0x0F) << 2) | ((i3 >> 6) & 0x03))]
                    buffer[outIndex + 3] = e1[Int(i3)]
                    outIndex += 4
                } else if let i2 = i2 {
                    buffer[outIndex + 1] = e1[Int(((i1 & 0x03) << 4) | ((i2 >> 4) & 0x0F))]
                    buffer[outIndex + 2] = e1[Int((i2 & 0x0F) << 2)]
                    outIndex += 3
                    if !omitPaddingCharacter {
                        buffer[outIndex] = Self.encodePaddingCharacter
                        outIndex += 1
                    }
                } else {
                    buffer[outIndex + 1] = e1[Int((i1 & 0x03) << 4)]
                    outIndex += 2
                    if !omitPaddingCharacter {
                        buffer[outIndex] = Self.encodePaddingCharacter
                        buffer[outIndex + 1] = Self.encodePaddingCharacter
                        outIndex += 2
                    }
                }
            }

            return outIndex
        }
    }

    @inlinable
    static func withUnsafeEncodingTablesAsBufferPointers<R>(
        options: Base64.EncodingOptions, _ body: (UnsafeBufferPointer<UInt8>, UnsafeBufferPointer<UInt8>) throws -> R
    ) rethrows -> R {
        let encoding0 = options.contains(.base64UrlAlphabet) ? Self.encoding0url : Self.encoding0
        let encoding1 = options.contains(.base64UrlAlphabet) ? Self.encoding1url : Self.encoding1

        assert(encoding0.count == 256)
        assert(encoding1.count == 256)

        return try encoding0.withUnsafeBufferPointer { e0 -> R in
            try encoding1.withUnsafeBufferPointer { e1 -> R in
                try body(e0, e1)
            }
        }
    }
}

// MARK: - Decoding -

extension Base64 {
    public struct DecodingOptions: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let base64UrlAlphabet = DecodingOptions(rawValue: UInt(1 << 0))
        public static let omitPaddingCharacter = DecodingOptions(rawValue: UInt(1 << 1))
    }

    public struct DecodingError: Error, Equatable, Sendable {
        fileprivate enum _Internal: Error, Equatable {
            case invalidLength
            case invalidCharacter(UInt8)
            case unexpectedPaddingCharacter
            case unexpectedEnd
        }

        fileprivate let value: _Internal
        fileprivate init(_ value: _Internal) {
            self.value = value
        }

        public static var invalidLength: Self { .init(.invalidLength) }
        public static func invalidCharacter(_ character: UInt8) -> Self { .init(.invalidCharacter(character)) }
        public static var unexpectedPaddingCharacter: Self { .init(.unexpectedPaddingCharacter) }
        public static var unexpectedEnd: Self { .init(.unexpectedEnd) }
    }

    @inlinable
    public static func decodedLength(bytesCount count: Int) -> Int {
        ((count + 3) / 4) * 3
    }

    @inlinable
    public static func decode(string encoded: String, options: DecodingOptions = []) throws -> [UInt8] {
        let decoded = try encoded.utf8.withContiguousStorageIfAvailable { characterPointer -> [UInt8] in
            guard characterPointer.count > 0 else {
                return []
            }

            let outputLength = decodedLength(bytesCount: characterPointer.count)

            return try characterPointer.withMemoryRebound(to: UInt8.self) { input -> [UInt8] in
                try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                    length = try Self._decodeChromium(from: input, into: output, options: options)
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

    @inlinable
    public static func decode(bytes: some Collection<UInt8>, options: DecodingOptions = []) throws -> [UInt8] {
        guard bytes.count > 0 else {
            return []
        }

        let decoded = try bytes.withContiguousStorageIfAvailable { input -> [UInt8] in
            let outputLength = decodedLength(bytesCount: input.count)

            return try [UInt8](unsafeUninitializedCapacity: outputLength) { output, length in
                length = try Self._decodeChromium(from: input, into: output, options: options)
            }
        }

        if let decoded {
            return decoded
        }

        return try self.decode(bytes: Array(bytes), options: options)
    }

    /// Write the base64 decoding of `bytes` to `output`.
    ///
    /// `output` must be at least `decodedLength(bytesCount:)` bytes long.
    ///
    /// - Returns: The number of bytes written to `output`.
    @inlinable
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
    /// - Returns: The number of bytes appended to `output`.
    @inlinable
    @discardableResult
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

    @inlinable
    static func _decodeChromium(
        from inBuffer: UnsafeBufferPointer<UInt8>,
        into outBuffer: UnsafeMutableBufferPointer<UInt8>,
        options: DecodingOptions = []
    ) throws -> Int {
        let remaining = inBuffer.count % 4
        switch (options.contains(.omitPaddingCharacter), remaining) {
        case (false, 1...):
            throw DecodingError.invalidLength
        case (true, 1):
            throw DecodingError.invalidLength
        default:
            // everything alright so far
            break
        }

        let outputLength = decodedLength(bytesCount: inBuffer.count)
        let fullchunks = remaining == 0 ? inBuffer.count / 4 - 1 : inBuffer.count / 4
        guard outBuffer.count >= outputLength else {
            preconditionFailure("Expected the out buffer to be at least as long as outputLength")
        }

        return try Self.withUnsafeDecodingTablesAsBufferPointers(options: options) { d0, d1, d2, d3 in
            var outIndex = 0
            if fullchunks > 0 {
                for chunk in 0..<fullchunks {
                    let inIndex = chunk * 4
                    let a0 = inBuffer[inIndex]
                    let a1 = inBuffer[inIndex + 1]
                    let a2 = inBuffer[inIndex + 2]
                    let a3 = inBuffer[inIndex + 3]
                    var x: UInt32 = d0[Int(a0)] | d1[Int(a1)] | d2[Int(a2)] | d3[Int(a3)]

                    if x >= Self.badCharacter {
                        // TODO: Inspect characters here better
                        throw DecodingError.invalidCharacter(inBuffer[inIndex])
                    }

                    withUnsafePointer(to: &x) { ptr in
                        ptr.withMemoryRebound(to: UInt8.self, capacity: 4) { newPtr in
                            outBuffer[outIndex] = newPtr[0]
                            outBuffer[outIndex + 1] = newPtr[1]
                            outBuffer[outIndex + 2] = newPtr[2]
                            outIndex += 3
                        }
                    }
                }
            }

            // inIndex is the first index in the last chunk
            let inIndex = fullchunks * 4
            let a0 = inBuffer[inIndex]
            let a1 = inBuffer[inIndex + 1]
            var a2: UInt8?
            var a3: UInt8?
            if inIndex + 2 < inBuffer.count, inBuffer[inIndex + 2] != Self.encodePaddingCharacter {
                a2 = inBuffer[inIndex + 2]
            }
            if inIndex + 3 < inBuffer.count, inBuffer[inIndex + 3] != Self.encodePaddingCharacter {
                a3 = inBuffer[inIndex + 3]
            }

            var x: UInt32 = d0[Int(a0)] | d1[Int(a1)] | d2[Int(a2 ?? 65)] | d3[Int(a3 ?? 65)]
            if x >= Self.badCharacter {
                // TODO: Inspect characters here better
                throw DecodingError.invalidCharacter(inBuffer[inIndex])
            }

            withUnsafePointer(to: &x) { ptr in
                ptr.withMemoryRebound(to: UInt8.self, capacity: 4) { newPtr in
                    outBuffer[outIndex] = newPtr[0]
                    outIndex += 1
                    if a2 != nil {
                        outBuffer[outIndex] = newPtr[1]
                        outIndex += 1
                    }
                    if a3 != nil {
                        outBuffer[outIndex] = newPtr[2]
                        outIndex += 1
                    }
                }
            }

            return outIndex
        }
    }

    @usableFromInline
    static func withUnsafeDecodingTablesAsBufferPointers<R>(
        options: Base64.DecodingOptions,
        _ body:
            (UnsafeBufferPointer<UInt32>, UnsafeBufferPointer<UInt32>, UnsafeBufferPointer<UInt32>, UnsafeBufferPointer<UInt32>) throws -> R
    ) rethrows -> R {
        let decoding0 = options.contains(.base64UrlAlphabet) ? Self.decoding0url : Self.decoding0
        let decoding1 = options.contains(.base64UrlAlphabet) ? Self.decoding1url : Self.decoding1
        let decoding2 = options.contains(.base64UrlAlphabet) ? Self.decoding2url : Self.decoding2
        let decoding3 = options.contains(.base64UrlAlphabet) ? Self.decoding3url : Self.decoding3

        assert(decoding0.count == 256)
        assert(decoding1.count == 256)
        assert(decoding2.count == 256)
        assert(decoding3.count == 256)

        return try decoding0.withUnsafeBufferPointer { d0 -> R in
            try decoding1.withUnsafeBufferPointer { d1 -> R in
                try decoding2.withUnsafeBufferPointer { d2 -> R in
                    try decoding3.withUnsafeBufferPointer { d3 -> R in
                        try body(d0, d1, d2, d3)
                    }
                }
            }
        }
    }
}
