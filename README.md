# swift-extras-base64

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org/download/)
[![github-actions](https://github.com/swift-extras/swift-extras-base64/workflows/CI/badge.svg)](https://github.com/swift-extras/swift-extras-base64/actions)
[![codecov](https://codecov.io/gh/swift-extras/swift-extras-base64/branch/main/graph/badge.svg)](https://codecov.io/gh/swift-extras/swift-extras-base64)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)


This package provides a base64 encoder and decoder in Swift without the use of Foundation. The implementation is [RFC4648](https://tools.ietf.org/html/rfc4648) complient and is faster than the Foundation base64 implementation.

To achieve performance the implementation uses [Chromium precomputed lookup tables](https://github.com/lemire/fastbase64/blob/master/src/chromiumbase64.c) and makes heavy use of unsafe swift API. When Swift has better support for SIMD instructions this might be an area worth exploring.

## Status

- [x] support for base64 and base64url 
- [x] faster than Foundation
- [x] padding can be omitted
- [ ] decoding can ignore line breaks
- [ ] encoding can insert line breaks

A former implementation of this package [is used in `swift-nio`'s websocket implementation](https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocket/Base64.swift).

## Performance

Super [simple performance test](https://github.com/swift-extras/swift-extras-base64/blob/main/Sources/PerformanceTest/main.swift) 
to ensure speediness of this implementation. Encoding and decoding 1m times the base64 string:

```
AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==
```

Tests were run on a MacBook Pro (16-inch, late 2019). Processor: 2.4 GHz 8-Core Intel Core i9.

#### macOS - swift 5.3

|  | Encoding | Decoding |
|:--|:--|:--|
| Foundation   | 2.08s | 2.15s |
| swift-extras-base64 | 0.66s | 0.54s |
| Speedup | 3x | 4x |

#### Linux - swift 5.3

|  | Encoding | Decoding |
|:--|:--|:--|
| Foundation   | 1.01s | 5.5s |
| swift-extras-base64 | 0.27s | 0.41s |
| Speedup | 3x | **~10x** |

## Literature for a faster algorithm

I would really like to speed up this project further to be way faster than it is today. Some food for thought of how this could be tackled can be found here:

- [Wojciech Muła, Daniel Lemire: Faster Base64 Encoding and Decoding using AVX2 Instructions](https://arxiv.org/pdf/1704.00605.pdf).
- [Daniel Lemire's blog - Ridiculously fast base64 encoding and decoding](https://lemire.me/blog/2018/01/17/ridiculously-fast-base64-encoding-and-decoding/)
- [Swift SIMD support](https://github.com/apple/swift-evolution/blob/master/proposals/0229-simd.md)

## Alternatives

As of today (2019-12-10), the author is aware of only one alternative that offers merely encoding.

- [SwiftyBase64](https://github.com/drichardson/SwiftyBase64)
