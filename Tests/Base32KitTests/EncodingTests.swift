import XCTest
@testable import Base32Kit

final class EncodingTests: XCTestCase {

    public static var allTests = [
        // Normal alphabet tests:
        ("testRFC4648TestVectors", testRFC4648TestVectors),
        ("testSentences", testSentences),
        ("testEmoji", testEmoji),

        // Hex alphabet tests:
        ("testHexRFC4648TestVectors", testHexRFC4648TestVectors),
        ("testHexSentences", testHexSentences),
        ("testHexEmoji", testHexEmoji),

        // General tests:
        ("testCapacityFormula", testCapacityFormula)
    ]

    func testRFC4648TestVectors() {
        let testData: [String: String] = [
            "": "",
            "f": "MY======",
            "fo": "MZXQ====",
            "foo": "MZXW6===",
            "foob": "MZXW6YQ=",
            "fooba": "MZXW6YTB",
            "foobar": "MZXW6YTBOI======"
        ]

        for (input, expected) in testData {
            let encoded = Base32.encode(string: input)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(input)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testSentences() {
        // See: https://en.wikipedia.org/wiki/Harvard_sentences
        let sentences: [String: String] = [
            "Oak is strong and also gives shade.": "J5QWWIDJOMQHG5DSN5XGOIDBNZSCAYLMONXSAZ3JOZSXGIDTNBQWIZJO",
            "Cats and dogs each hate the other.": "INQXI4ZAMFXGIIDEN5TXGIDFMFRWQIDIMF2GKIDUNBSSA33UNBSXELQ=",
            "The pipe began to rust while new.": "KRUGKIDQNFYGKIDCMVTWC3RAORXSA4TVON2CA53INFWGKIDOMV3S4===",
            "Open the crate but don't break the glass.":
                "J5YGK3RAORUGKIDDOJQXIZJAMJ2XIIDEN5XCO5BAMJZGKYLLEB2GQZJAM5WGC43TFY======",
            "Add the sum to the product of these three.":
                "IFSGIIDUNBSSA43VNUQHI3ZAORUGKIDQOJXWI5LDOQQG6ZRAORUGK43FEB2GQ4TFMUXA====",
            "Thieves who rob friends deserve jail.": "KRUGSZLWMVZSA53IN4QHE33CEBTHE2LFNZSHGIDEMVZWK4TWMUQGUYLJNQXA====",
            "The ripe taste of cheese improves with age.":
                "KRUGKIDSNFYGKIDUMFZXIZJAN5TCAY3IMVSXGZJANFWXA4TPOZSXGIDXNF2GQIDBM5SS4===",
            "Act on these orders with great speed.": "IFRXIIDPNYQHI2DFONSSA33SMRSXE4ZAO5UXI2BAM5ZGKYLUEBZXAZLFMQXA====",
            "The hog crawled under the high fence.": "KRUGKIDIN5TSAY3SMF3WYZLEEB2W4ZDFOIQHI2DFEBUGSZ3IEBTGK3TDMUXA====",
            "Move the vat over the hot fire.": "JVXXMZJAORUGKIDWMF2CA33WMVZCA5DIMUQGQ33UEBTGS4TFFY======"
        ]

        for (sentence, expected) in sentences {
            let encoded = Base32.encode(string: sentence)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(sentence)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testCapacityFormula() {
        let testData: [Int: Int] = [
            1: 8,
            2: 8,
            3: 8,
            4: 8,
            5: 8,
            6: 16,
            10: 16,
            11: 24,
            20: 32,
            21: 40,
            100: 160
        ]

        for (count, expectedCapacity) in testData {
            let result = ((count + 4) / 5) * 8
            XCTAssertEqual(result, expectedCapacity)
        }
    }

    func testEmoji() throws {
        let testData: [String: String] = [
            "😀": "6CPZRAA=",
            "Hello World ❤️": "JBSWY3DPEBLW64TMMQQOFHNE564I6==="
        ]

        for (input, expected) in testData {
            let encoded = Base32.encode(string: input)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(input)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testHexRFC4648TestVectors() {
        let stringsToEncode: [String: String] = [
            "": "",
            "f": "CO======",
            "fo": "CPNG====",
            "foo": "CPNMU===",
            "foob": "CPNMUOG=",
            "fooba": "CPNMUOJ1",
            "foobar": "CPNMUOJ1E8======"
        ]

        for (stringToEncode, expected) in stringsToEncode {
            let encoded = Base32.encodeHex(string: stringToEncode)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(stringToEncode)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testHexSentences() {
        // See: https://en.wikipedia.org/wiki/Harvard_sentences
        let sentences: [String: String] = [
            "Oak is strong and also gives shade.": "9TGMM839ECG76T3IDTN6E831DPI20OBCEDNI0PR9EPIN683JD1GM8P9E",
            "Cats and dogs each hate the other.": "8DGN8SP0C5N68834DTJN6835C5HMG838C5Q6A83KD1II0RRKD1IN4BG=",
            "The pipe began to rust while new.": "AHK6A83GD5O6A832CLJM2RH0EHNI0SJLEDQ20TR8D5M6A83ECLRIS===",
            "Open the crate but don't break the glass.":
                "9TO6ARH0EHK6A833E9GN8P90C9QN8834DTN2ET10C9P6AOBB41Q6GP90CTM62SRJ5O======",
            "Add the sum to the product of these three.":
                "85I6883KD1II0SRLDKG78RP0EHK6A83GE9NM8TB3EGG6UPH0EHK6ASR541Q6GSJ5CKN0====",
            "Thieves who rob friends deserve jail.": "AHK6IPBMCLPI0TR8DSG74RR241J74QB5DPI76834CLPMASJMCKG6KOB9DGN0====",
            "The ripe taste of cheese improves with age.":
                "AHK6A83ID5O6A83KC5PN8P90DTJ20OR8CLIN6P90D5MN0SJFEPIN683ND5Q6G831CTIIS===",
            "Act on these orders with great speed.": "85HN883FDOG78Q35EDII0RRICHIN4SP0ETKN8Q10CTP6AOBK41PN0PB5CGN0====",
            "The hog crawled under the high fence.": "AHK6A838DTJI0ORIC5RMOPB441QMSP35E8G78Q3541K6IPR841J6ARJ3CKN0====",
            "Move the vat over the hot fire.": "9LNNCP90EHK6A83MC5Q20RRMCLP20T38CKG6GRRK41J6ISJ55O======"
        ]

        for (sentence, expected) in sentences {
            let encoded = Base32.encodeHex(string: sentence)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(sentence)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testHexEmoji() throws {
        let testData: [String: String] = [
            "😀": "U2FPH00=",
            "Hello World ❤️": "91IMOR3F41BMUSJCCGGE57D4TUS8U==="
        ]

        for (input, expected) in testData {
            let encoded = Base32.encodeHex(string: input)
            XCTAssertEqual(
                encoded,
                expected,
                "Input '\(input)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }
}
