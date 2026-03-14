import Testing
@testable import OrchivisteKitObservability

struct ObservabilityTests {
    @Test
    func inMemoryLoggerStoresEvents() {
        let logger = InMemoryLogger()
        let event = LogEvent(
            timestamp: "2026-03-14T00:00:00Z",
            level: .info,
            message: "hello",
            correlationID: "corr-1",
            requestID: "req-1",
            tool: "MuniAnalyse",
            metadata: ["key": "value"]
        )

        logger.log(event)

        #expect(logger.events.count == 1)
        #expect(logger.events.first?.message == "hello")
        #expect(logger.events.first?.metadata["key"] == "value")
    }
}
