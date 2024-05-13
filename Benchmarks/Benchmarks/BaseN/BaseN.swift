import Benchmark
import ExtrasBase64

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
            blackHole(try Base32.decode(string: base32))
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
            blackHole(try Base64.decode(string: base64))
        }
    }
}
