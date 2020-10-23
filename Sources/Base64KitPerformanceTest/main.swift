import Base64Kit
import Foundation

let base64 = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="

let runs = 1_000_000
let bytes = Array(UInt8(0) ... UInt8(255))

@discardableResult
func timing(name: String, execute: () -> Void) -> TimeInterval {
    let start = Date()
    execute()
    let time = -start.timeIntervalSinceNow
    print("\(name) | took: \(time)s")
    return time
}

print("Number of invocations: \(runs)")

print("------------------------------------------")
print("Encoding")

let data = Data(bytes)
let foundationEncodingString = timing(name: "Foundation: Data to String  ") {
    for _ in 1 ... runs {
        _ = data.base64EncodedString()
    }
}

let foundationEncodingData = timing(name: "Foundation: Data to Data    ") {
    for _ in 1 ... runs {
        _ = data.base64EncodedData()
    }
}

let chromeEncodingBytes = timing(name: "Chromium: [UInt8] to [UInt8]") {
    for _ in 1 ... runs {
        let _ : [UInt8] = Base64.encode(bytes: bytes)
    }
}

let chromeEncodingString = timing(name: "Chromium: [UInt8] to String ") {
    for _ in 1 ... runs {
        let _ : String = Base64.encode(bytes: bytes)
    }
}

let chromeEncodingData = timing(name: "Chromium: Data    to [UInt8]") {
    for _ in 1 ... runs {
        let _ : String = Base64.encode(bytes: data)
    }
}

print("------------------------------------------")
print("Decoding")

let foundationDecodingFromString = timing(name: "Foundation: String to Data  ") {
    for _ in 1 ... runs {
        _ = Data(base64Encoded: base64)
    }
}

let encodedData = Data(base64.utf8)
let foundationDecodingFromData = timing(name: "Foundation: Data   to Data  ") {
    for _ in 1 ... runs {
        _ = Data(base64Encoded: encodedData)
    }
}

let encodedUInt8Array = Array(base64.utf8)
let chromeDecodingFromBytes = timing(name: "Chromium: [UInt8] to [UInt8]") {
    for _ in 1 ... runs {
        _ = try! Base64.decode(bytes: encodedUInt8Array)
    }
}

let chromeDecodingFromString = timing(name: "Chromium: String  to [UInt8]") {
    for _ in 1 ... runs {
        _ = try! Base64.decode(string: base64)
    }
}

let chromeDecodingFromData = timing(name: "Chromium: Data    to [UInt8]") {
    for _ in 1 ... runs {
        _ = try! Base64.decode(bytes: encodedData)
    }
}

// print("------------------------------------------")
// print("Results")

var result: Int32 = 0
//if foundationEncoding < base64Encoding {
//    print("Base64 encoding must be at least as fast as Foundation encoding")
//    result = 1
//}
//
//if foundationDecoding < base64Decoding {
//    print("Base64 decoding must be at least as fast as Foundation decoding")
//    result = 1
//}
//
//if result == 0 {
//    let encodingGain = round(foundationEncoding / base64Encoding * 1000) / 1000
//    let decodingGain = round(foundationDecoding / base64Decoding * 1000) / 1000
//    print("Encoding: \(encodingGain)x")
//    print("Decoding: \(decodingGain)x")
//}

exit(result)
