
public enum DecodingError: Error, Equatable {
    case invalidLength
    case invalidCharacter(UInt8)
    case illegalCharacter
    case unexpectedPaddingCharacter
    case unexpectedEnd

    /// Thrown when reading the encoded `String` and no character can be found at position one or two even though
    /// it should exist.
    case missingCharacter
}
