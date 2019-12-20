import Foundation
import Base64

let base64 = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="

let runs = 100000
let bytes = Array(UInt8(0)...UInt8(255))

@discardableResult
func timing(name: String, execute: () -> ()) -> TimeInterval {
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
let foundationEncoding = timing(name: "Foundation  ") {
  for _ in 1...runs {
    _ = data.base64EncodedString()
  }
}

let nioWebsocketEncoding = timing(name: "NIOWebsocket") {
  for _ in 1...runs {
    _ = String(niobase64Encoding: bytes)
  }
}

let base64Encoding = timing(name: "Base64      ") {
  for _ in 1...runs {
    _ = String(base64Encoding: bytes)
  }
}

print("------------------------------------------")
print("Decoding")

let foundationDecoding = timing(name: "Foundation  ") {
  for _ in 1...runs {
    _ = Data(base64Encoded: base64)
  }
}

let base64Decoding = timing(name: "Base64      ") {
  for _ in 1...runs {
    _ = try! base64.base64decoded()
  }
}

print("------------------------------------------")
print("Results")

var result: Int32 = 0
if foundationEncoding < base64Encoding {
  print("Base64 encoding must be at least as fast as Foundation encoding")
  result = 1
}
if foundationDecoding < base64Decoding {
  print("Base64 decoding must be at least as fast as Foundation decoding")
  result = 1
}

if result == 0 {
  let encodingGain = round(foundationEncoding / base64Encoding * 1000) / 1000
  let decodingGain = round(foundationDecoding / base64Decoding * 1000) / 1000
  print("Encoding: \(encodingGain)x")
  print("Decoding: \(decodingGain)x")
}

exit(result)

