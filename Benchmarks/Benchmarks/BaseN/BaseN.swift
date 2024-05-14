import Benchmark
import ExtrasBase64
import Foundation

let benchmarks = {
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .cpuTotal,
            .throughput,
            .mallocCountTotal,
        ],
        warmupIterations: 10,
        scalingFactor: .kilo
    )

    Benchmark("Base32.encode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(Base32.encodeToString(bytes: bytes))
        }
    }

    Benchmark("Base32.decode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let base32 = Base32.encodeToString(bytes: bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            try blackHole(Base32.decode(string: base32))
        }
    }

    Benchmark("Base32.decodeIgnoreNullCharacters") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let base32 = Base32.encodeToString(bytes: bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            try blackHole(Base32.decode(string: base32, options: .allowNullCharacters))
        }
    }

    Benchmark("Base64.encode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(Base64.encodeToString(bytes: bytes))
        }
    }

    Benchmark("Base64.decode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let base64 = Base64.encodeToString(bytes: bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            try blackHole(Base64.decode(string: base64))
        }
    }

    Benchmark("Foundation.encodeToData") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let data = Data(bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(data.base64EncodedData())
        }
    }

    Benchmark("Foundation.encodeToString") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let data = Data(bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(data.base64EncodedString())
        }
    }

    Benchmark("Foundation.decodeString") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let base64 = Base64.encodeToString(bytes: bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(Data(base64Encoded: base64))
        }
    }

    Benchmark("Foundation.decodeStringIgnoreUnknownCharacters") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))
        let base64 = Base64.encodeToString(bytes: bytes)

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(Data(base64Encoded: base64, options: .ignoreUnknownCharacters))
        }
    }
}
