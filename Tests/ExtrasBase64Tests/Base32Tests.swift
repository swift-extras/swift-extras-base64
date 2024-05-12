import ExtrasBase64
import XCTest

class Base32Tests: XCTestCase {
    // MARK: Encoding

    func testEncodeEmptyData() {
        let data = [UInt8]()
        let encodedData: [UInt8] = Base32.encodeBytes(bytes: data)
        XCTAssertEqual(encodedData.count, 0)
    }

    func testBase32EncodingArrayOfNulls() {
        let data = Array(repeating: UInt8(0), count: 10)
        let encodedData: [UInt8] = Base32.encodeBytes(bytes: data)
        XCTAssertEqual(encodedData, [UInt8]("AAAAAAAAAAAAAAAA".utf8))
    }

    func testBase32EncodingAllTheBytesSequentially() {
        let data = Array(UInt8(0) ... UInt8(255))
        let encodedData = Base32.encodeBytes(bytes: data)
        XCTAssertEqual(encodedData, [UInt8]("AAAQEAYEAUDAOCAJBIFQYDIOB4IBCEQTCQKRMFYYDENBWHA5DYPSAIJCEMSCKJRHFAUSUKZMFUXC6MBRGIZTINJWG44DSOR3HQ6T4P2AIFBEGRCFIZDUQSKKJNGE2TSPKBIVEU2UKVLFOWCZLJNVYXK6L5QGCYTDMRSWMZ3INFVGW3DNNZXXA4LSON2HK5TXPB4XU634PV7H7AEBQKBYJBMGQ6EITCULRSGY5D4QSGJJHFEVS2LZRGM2TOOJ3HU7UCQ2FI5EUWTKPKFJVKV2ZLNOV6YLDMVTWS23NN5YXG5LXPF5X274BQOCYPCMLRWHZDE4VS6MZXHM7UGR2LJ5JVOW27MNTWW33TO55X7A4HROHZHF43T6R2PK5PWO33XP6DY7F47U6X3PP6HZ7L57Z7P674".utf8))
    }

    // MARK: Decoding

    func testDecodeEmptyString() throws {
        var decoded: [UInt8]?
        XCTAssertNoThrow(decoded = try Base32.decode(string: ""))
        XCTAssertEqual(decoded?.count, 0)
    }

    func testDecodeEmptyBytes() throws {
        var decoded: [UInt8]?
        XCTAssertNoThrow(decoded = try Base32.decode(bytes: []))
        XCTAssertEqual(decoded?.count, 0)
    }

    func testBase32DecodingArrayOfNulls() throws {
        let expected = Array(repeating: UInt8(0), count: 10)
        var decoded: [UInt8]?
        var string = "AAAAAAAAAAAAAAAAA"
        string.makeContiguousUTF8()
        XCTAssertNoThrow(decoded = try Base32.decode(string: string))
        XCTAssertEqual(decoded, expected)
    }

    func testBase32DecodingAllTheBytesSequentially() {
        let base32 = "AAAQEAYEAUDAOCAJBIFQYDIOB4IBCEQTCQKRMFYYDENBWHA5DYPSAIJCEMSCKJRHFAUSUKZMFUXC6MBRGIZTINJWG44DSOR3HQ6T4P2AIFBEGRCFIZDUQSKKJNGE2TSPKBIVEU2UKVLFOWCZLJNVYXK6L5QGCYTDMRSWMZ3INFVGW3DNNZXXA4LSON2HK5TXPB4XU634PV7H7AEBQKBYJBMGQ6EITCULRSGY5D4QSGJJHFEVS2LZRGM2TOOJ3HU7UCQ2FI5EUWTKPKFJVKV2ZLNOV6YLDMVTWS23NN5YXG5LXPF5X274BQOCYPCMLRWHZDE4VS6MZXHM7UGR2LJ5JVOW27MNTWW33TO55X7A4HROHZHF43T6R2PK5PWO33XP6DY7F47U6X3PP6HZ7L57Z7P674"

        let expected = Array(UInt8(0) ... UInt8(255))
        var decoded: [UInt8]?
        XCTAssertNoThrow(decoded = try Base32.decode(bytes: base32.utf8))
        XCTAssertEqual(decoded, expected)
    }

    func testBase32DecodingWithPoop() {
        XCTAssertThrowsError(_ = try Base32.decode(bytes: "💩".utf8)) { error in
            XCTAssertEqual(error as? Base32.DecodingError, .invalidCharacter(240))
        }
    }

    func testBase32DecodingOneTwoThreeFour() {
        let base32 = "AEBAGBA"
        let bytes: [UInt8] = [1, 2, 3, 4]

        XCTAssertEqual(Base32.encodeString(bytes: bytes), base32)
        XCTAssertEqual(try Base32.decode(string: base32), bytes)
    }

    func testBase32DecodingOneTwoThreeFourFive() {
        let base32 = "AEBAGBAF"
        let bytes: [UInt8] = [1, 2, 3, 4, 5]

        XCTAssertEqual(Base32.encodeString(bytes: bytes), base32)
        XCTAssertEqual(try Base32.decode(string: base32), bytes)
    }

    func testBase32DecodingOneTwoThreeFourFiveSix() {
        let base32 = "AEBAGBAFAY"
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]

        XCTAssertEqual(Base32.encodeString(bytes: bytes), base32)
        XCTAssertEqual(try Base32.decode(string: base32), bytes)
    }

    func testBase32DecodingPadding() {
        let base32 = "AEBAGBAFAY======"
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]

        XCTAssertEqual(Base32.encodeString(bytes: bytes, options: .includePadding), base32)
        XCTAssertEqual(try Base32.decode(string: base32), bytes)
    }

    func testBase32EncodeFoobar() {
        XCTAssertEqual(String(base32Encoding: "".utf8), "")
        XCTAssertEqual(String(base32Encoding: "f".utf8), "MY")
        XCTAssertEqual(String(base32Encoding: "fo".utf8), "MZXQ")
        XCTAssertEqual(String(base32Encoding: "foo".utf8), "MZXW6")
        XCTAssertEqual(String(base32Encoding: "foob".utf8), "MZXW6YQ")
        XCTAssertEqual(String(base32Encoding: "fooba".utf8), "MZXW6YTB")
        XCTAssertEqual(String(base32Encoding: "foobar".utf8), "MZXW6YTBOI")
    }

    func testBase32EncodeFoobarWithPadding() {
        XCTAssertEqual(String(base32Encoding: "".utf8, options: .includePadding), "")
        XCTAssertEqual(String(base32Encoding: "f".utf8, options: .includePadding), "MY======")
        XCTAssertEqual(String(base32Encoding: "fo".utf8, options: .includePadding), "MZXQ====")
        XCTAssertEqual(String(base32Encoding: "foo".utf8, options: .includePadding), "MZXW6===")
        XCTAssertEqual(String(base32Encoding: "foob".utf8, options: .includePadding), "MZXW6YQ=")
        XCTAssertEqual(String(base32Encoding: "fooba".utf8, options: .includePadding), "MZXW6YTB")
        XCTAssertEqual(String(base32Encoding: "foobar".utf8, options: .includePadding), "MZXW6YTBOI======")
    }
}
