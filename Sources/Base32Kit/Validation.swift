extension Base32 {

    /// Validate the given `string` to be a "valid" Base 32 encoded string.
    ///
    /// The following criteria is validated:
    ///
    /// - length (must be a multiple of 8)
    /// - only contains legal characters as defined by the `legalCharacters`
    /// - contain only valid padding.
    ///
    /// - Parameters:
    ///     - string: the encoded string to validate.
    ///     - legalCharacters: a `String` containing all legal characters.
    ///
    /// - Throws:
    ///     - `Base32.DecodingError.invalidLength`
    ///        if encoded string has invalid length (is not a multiple of 8 or empty).
    ///     - `Base32.DecodingError.illegalCharactersFound`
    ///        if encoded string contains one or more illegal characters.
    ///     - `Base32.DecodingError.invalidPaddingCharacters`
    ///        if encoded string contains a padding character (`=`) at an illegal position.
    static func validate(string: String, legalCharacters: String) throws {
        guard string.count % 8 == 0 else {
            throw Base32.DecodingError.invalidLength
        }

        if let illegalCharacters = findIllegalCharacters(in: string, legalCharacters: legalCharacters) {
            throw Base32.DecodingError.illegalCharactersFound(illegalCharacters)
        }

        if invalidPadding(in: string) {
            throw Base32.DecodingError.invalidPaddingCharacters
        }
    }

    /// Determines whether the given `string` contains invalid padding.
    ///
    /// Padding is only allowed at certain places of a Base 32 encoded `String`:
    ///
    /// - No padding as first character.
    /// - Only the last 6 characters can contain padding.
    /// - The last 6 characters can only contain 6, 4, 3 or 1 padding characters.
    ///
    /// Valid padding:
    ///
    /// ```
    /// [...]AB====== (6 x =)
    /// [...]ABCD==== (4 x =)
    /// [...]ABCDE=== (3 x =)
    /// [...]ABCDEFG= (1 x =)
    /// [...]ABCDEFGH (0 x =)
    /// ```
    ///
    /// Note: `[...]` signifies possible prior encoded string fragments.
    ///
    /// Any padding that is not placed as above is considered invalid.
    ///
    /// - Parameter string: The encoded string to check for invalid padding.
    ///
    /// - Returns: true if the given `string` contains invalid padding, otherwise false.
    ///
    /// - Complexity: O(n)
    static func invalidPadding(in string: String) -> Bool {
        if string.starts(with: "=") {
            return true
        }

        guard let firstPaddingIndex = string.firstIndex(of: "=") else {
            return false
        }

        // There are three places where padding is not allowed, but would look valid to the other tests in this method.
        //
        // Consider the following pseudo encoded string: "ABCDEFGH"
        //
        // This code has 8 characters, which is valid and no padding, which would also be valid. According section 6 of
        // RFC 4648 the only valid padding "configurations" would be as follows:
        //
        // ABCDEFGH (0 x =)
        // ABCDEFG= (1 x =)
        // ABCDE=== (3 x =)
        // ABCD==== (4 x =)
        // AB====== (6 x =)
        //
        // The following "configurations" would not be allowed:
        //
        // ABCDEF== (2 x =)
        // ABC===== (5 x =)
        // A======= (7 x =)
        // ======== (8 x =)
        //
        // The following table details the above rule:
        //
        //                 ┌───┬───┬───┬───┬───┬───┬───┬───┐
        //                 │ A │ B │ C │ D │ E │ F │ G │ H │
        // ┌───────────────┼───┼───┼───┼───┼───┼───┼───┼───┤
        // │   String Index│ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │
        // ├───────────────┼───┼───┼───┼───┼───┼───┼───┼───┤
        // │endIndex offset│-8 │-7 │-6 │-5 │-4 │-3 │-2 │-1 │
        // └───────────────┴─▲─┴─▲─┴───┴─▲─┴───┴───┴─▲─┴───┘
        //                   │   │       │           │
        //                   │   │       │           │
        //                  Not allowed to contain padding
        //
        if firstPaddingIndex == string.index(string.endIndex, offsetBy: -2) ||
            firstPaddingIndex == string.index(string.endIndex, offsetBy: -5) ||
            firstPaddingIndex == string.index(string.endIndex, offsetBy: -7) {
            return true
        }

        // Find the first padding character and check that none of the following characters is something other than a
        // padding character.
        let padding = string[firstPaddingIndex..<string.endIndex]
        return !padding.allSatisfy({ $0 == "=" })
    }

    /// Returns a `Set` of characters that is in the given `string` but not in the given `legalCharacters`.
    ///
    /// - Parameters:
    ///     - string: the `String` in to check for illegal characters.
    ///     - legalCharacters: a `String` that contains all legal characters.
    ///
    /// - Returns: Set of illegal characters found in the given `string` or `nil` if no illegal character was found.
    ///
    /// - Complexity: O(n)
    private static func findIllegalCharacters(in string: String, legalCharacters: String) -> Set<Character>? {
        let illegalCharacters = string.filter({ !legalCharacters.contains($0) })
        return illegalCharacters.isEmpty ? nil : Set<Character>(illegalCharacters)
    }
}
