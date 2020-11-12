import ExtrasBase64

func run(identifier: String) {
    let bytes = Array(UInt8(0) ... UInt8(255))
    var base64: String?

    measure(identifier: identifier) {
        for _ in 0 ..< 1000 {
            base64 = Base64.encodeString(bytes: bytes)
        }

        return base64?.count ?? 0
    }
}
