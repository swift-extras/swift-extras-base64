# swift-base64

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org/download/)
[![github-actions](https://github.com/fabianfett/swift-base64/workflows/CI/badge.svg)](https://github.com/fabianfett/swift-base64/actions)
[![codecov](https://codecov.io/gh/fabianfett/swift-base64/branch/master/graph/badge.svg)](https://codecov.io/gh/fabianfett/swift-base64)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)


This project provides a base64 encoder and decoder in pure Swift (without the use of Foundation). The implementation is [RFC4648](https://tools.ietf.org/html/rfc4648) complient.

Today the implementation is rather simple. No fancy precomputed lookup tables, no fancy SIMD instructions. Therefore, there is definitely room for improvement performance wise. See also [Literature for a faster algorithm](#user-content-literature-for-a-faster-algorithm)

Everything began with [an issue](https://github.com/apple/swift-nio/issues/1265) on [`swift-nio`](https://github.com/apple/swift-nio).

## Status

- [x] support for base64 and base64url 
- [x] faster than Foundation
- [ ] decoding can ignore line breaks
- [ ] encoding can insert line breaks
- [ ] 100% test coverage

## Performance

Super [simple performance test](https://github.com/fabianfett/swift-base64/blob/master/Sources/Base64PerformanceTest/main.swift) 
to ensure speediness of this implementation. Encoding and decoding 1m times the base64 string:

```
AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==
```

#### macOS

MacBook Pro (15-inch, late 2016 - the first one with the butterfly keyboard). 
Quad Core 2,7 GHz Intel Core i7

|  | Encoding | Decoding |
|:--|:--|:--|
| Foundation   | 2.21s | 2.28s |
| swift-base64 | 1.01s | 1.06s |
| Speedup | 2.18x | 2.14x |

#### linux

Whatevar runs GitHub Actions 😉

|  | Encoding | Decoding |
|:--|:--|:--|
| Foundation   | 33.64s | 3.49s |
| swift-base64 | 1.07s | 1.27s |
| Speedup | **31.18x** | 2.74x |

I have no idea why Foundation base64 encoding is so slow on linux. 🤷‍♂️

## Literature for a faster algorithm

I would really like to speed up this project further to be way faster than it is today. Some food for thought of how this could be approached can be found here:

- [Chromium precomputed lookup tables](https://github.com/lemire/fastbase64/blob/master/src/chromiumbase64.c)
- [Wojciech Muła, Daniel Lemire: Faster Base64 Encoding and Decoding using AVX2 Instructions](https://arxiv.org/pdf/1704.00605.pdf).
- [Daniel Lemire's blog - Ridiculously fast base64 encoding and decoding](https://lemire.me/blog/2018/01/17/ridiculously-fast-base64-encoding-and-decoding/)
- [Swift SIMD support](https://github.com/apple/swift-evolution/blob/master/proposals/0229-simd.md)

## Alternatives

As of today (2019-12-10) the author is only aware of two alternatives that both offer only encoding.

- [SwiftyBase64](https://github.com/drichardson/SwiftyBase64)
- [NIOWebSocket - Base64](https://github.com/apple/swift-nio/blob/master/Sources/NIOWebSocket/Base64.swift)

