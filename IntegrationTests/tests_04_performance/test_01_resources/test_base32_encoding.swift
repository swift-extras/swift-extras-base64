import ExtrasBase64

func run(identifier: String) {
    let bytes = Array(UInt8(0) ... UInt8(255))
    var base32: String?

    measure(identifier: identifier) {
        for _ in 0 ..< 1000 {
            base32 = Base32.encodeToString(bytes: bytes)
        }

        return base32?.count ?? 0
    }
}
