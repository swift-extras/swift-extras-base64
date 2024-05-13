import Benchmark
import ExtrasBase64

let benchmarks = {
    Benchmark.defaultConfiguration = .init(
        metrics: [
            .cpuTotal,
            .throughput,
            .mallocCountTotal,
        ],
        warmupIterations: 10
    )

    Benchmark("Base32encode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))

//        benchmark.startMeasurement()

        blackHole(Base32.encodeToString(bytes: bytes))
    }

    Benchmark("Base64encode") { benchmark in
        let bytes = Array(UInt8(0) ... UInt8(255))

//        benchmark.startMeasurement()

        blackHole(Base64.encodeToString(bytes: bytes))
    }
}
