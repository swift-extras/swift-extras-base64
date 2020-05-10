extension Base32 {

    /// Errors that can be thrown during decoding of a Base 32 encoded string.
    public enum DecodingError: Error, Equatable {

        /// The `String` to decode has invalid length. A string that should be decoded should have a length that is a
        /// multiple of 8 (e.g. 8 characters, 16, 24 ... 80, 96, etc.)
        case invalidLength

        /// Thrown when the encoded `String` contains illegal characters.
        ///
        /// Base 32 Encoding only supports a very limited set of legal characters to which data can be encoded to. If a
        /// given _encoded_ `String` contains characters that are not part of this alphabet, this error is thrown.
        ///
        /// The error contains a `Set` of all the illegal `Character`s that were found.
        ///
        /// ```
        /// do {
        ///     let decoded = try Base32.decode("1=======") // The character "1" is not a legal character
        /// } catch Base32.DecodingError.illegalCharactersFound(let illegalCharacters) {
        ///     print("Given string can not be decoded because it contains illegal characters: \(illegalCharacters)")
        /// }
        /// ```
        case illegalCharactersFound(Set<Character>)

        /// Thrown when the encoded  `String` contains one or more invalid padding characters (`=`).
        ///
        /// Padding characters are only allowed at the end of the encoded string and no other character is allowed
        /// to follow.
        ///
        /// Examples:
        /// - OK: `"MZXQ===="`
        /// - Not OK: `"M=XQ===="`
        case invalidPaddingCharacters

        /// Thrown when reading the encoded `String` and no character can be found at position one or two even though
        /// it should exist.
        case missingCharacter
    }
}
