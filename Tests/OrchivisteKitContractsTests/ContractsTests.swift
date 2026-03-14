import Foundation
import Testing
@testable import OrchivisteKitContracts

struct ContractsTests {
    @Test
    func toolStatusAllowedValuesIncludeNotImplemented() {
        #expect(ToolStatus.allCases.map(\.rawValue) == [
            "queued",
            "running",
            "succeeded",
            "failed",
            "needs_review",
            "cancelled",
            "not_implemented"
        ])
    }

    @Test
    func toolResultRoundTrip() throws {
        let request = ToolRequest(requestID: "req-1", tool: "MuniAnalyse", action: "run")
        let result = ToolResult(
            requestID: request.requestID,
            tool: request.tool,
            status: .notImplemented,
            errors: [ToolError(code: "NOT_IMPLEMENTED", message: "Not implemented")]
        )

        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(ToolResult.self, from: data)

        #expect(decoded.status == ToolStatus.notImplemented)
        #expect(decoded.requestID == "req-1")
        #expect(decoded.errors.first?.code == "NOT_IMPLEMENTED")
    }
}
