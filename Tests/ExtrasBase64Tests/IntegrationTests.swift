import Testing

@testable import ExtrasBase64

@Suite
struct IntegrationTests {
    @Test
    func encodeAndDecodingĨ() throws {
        var input = "Ĩ"
        let encoded = input.withUTF8 { ptr -> String in
            Base64.encodeToString(bytes: ptr)
        }

        let decoded = try Base64.decode(string: encoded)
        let output = String(decoding: decoded, as: Unicode.UTF8.self)

        #expect(input == output)
    }
}
