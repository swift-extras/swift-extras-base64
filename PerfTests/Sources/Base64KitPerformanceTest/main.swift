import Foundation
import Base64Kit
import NIO

let base64 = "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="

let runs = 1_000_000
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
print("Pure iterating")

let pureReading = timing(name: "Reading an [UInt8] array") {
  for _ in 1...runs {
    var iterator = bytes.makeIterator()
    while let value = iterator.next() {
      _ = value
    }
  }
}

print("------------------------------------------")
print("Encoding")

let foundationData = Data(bytes)
let foundationEncoding = timing(name: "Foundation on Data      ") {
  for _ in 1...runs {
    _ = foundationData.base64EncodedString()
  }
}

let base64BytesEncoding = timing(name: "Base64 on [UInt8]       ") {
  for _ in 1...runs {
    _ = Base64.encode(bytes: bytes)
  }
}

let base64DataEncoding = timing(name: "Base64 on Data          ") {
  for _ in 1...runs {
    _ = Base64.encode(bytes: foundationData)
  }
}

let allocator = ByteBufferAllocator()
let base64NIOByteBufferEncoding = timing(name: "Base64 on NIO.ByteBuffer") {
  for _ in 1...runs {
    var buffer = allocator.buffer(capacity: bytes.count)
    buffer.writeBytes(bytes)
    _ = Base64.encode(bytes: buffer.readableBytesView)
  }
}

print("------------------------------------------")
print("Decoding")

let base64Data = base64.data(using: .utf8)!
let foundationDataDecoding = timing(name: "Foundation on Data      ") {
  for _ in 1...runs {
    _ = Data(base64Encoded: base64Data)
  }
}

let foundationStringDecoding = timing(name: "Foundation on String    ") {
  for _ in 1...runs {
    _ = Data(base64Encoded: base64)
  }
}

let base64DataDecoding = timing(name: "Base64 on Data          ") {
  for _ in 1...runs {
    _ = try! Base64.decode(encoded: base64Data)
  }
}

let base64StringDecoding = timing(name: "Base64 on String        ") {
  for _ in 1...runs {
    _ = try! Base64.decode(encoded: base64)
  }
}

let base64Bytes = [UInt8](base64.utf8)
let base64BytesDecoding = timing(name: "Base64 on [UInt8]       ") {
  for _ in 1...runs {
    _ = try! Base64.decode(encoded: base64Bytes)
  }
}

let base64NIOByteBufferDecoding = timing(name: "Base64 on NIO.ByteBuffer") {
  for _ in 1...runs {
    var buffer = allocator.buffer(capacity: base64Bytes.count)
    buffer.writeBytes(base64Bytes)
    _ = try! Base64.decode(encoded: buffer.readableBytesView)
  }
}

print("------------------------------------------")
print("Results")

//var result: Int32 = 0
//if foundationEncoding < base64BytesEncoding {
//  print("Base64 encoding must be at least as fast as Foundation encoding")
//  result = 1
//}
//if foundationDecoding < base64Decoding {
//  print("Base64 decoding must be at least as fast as Foundation decoding")
//  result = 1
//}
//
//if result == 0 {
//  let encodingGain = round(foundationEncoding / base64BytesEncoding * 1000) / 1000
//  let decodingGain = round(foundationDecoding / base64Decoding * 1000) / 1000
//  print("Encoding: \(encodingGain)x")
//  print("Decoding: \(decodingGain)x")
//}
//
//exit(result)

