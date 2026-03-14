import Foundation
import Testing
@testable import OrchivisteKitContracts
@testable import OrchivisteKitInterop

struct InteropTests {
    @Test
    func writeAndReadRequest() throws {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("orchivistekit-request-\(UUID().uuidString).json")

        let request = ToolRequest(requestID: "req-interop", tool: "MuniAnalyse", action: "run")
        try JSONFileCodec.encode(request, to: tmp)

        let decoded = try ToolInteropService.loadRequest(from: tmp)
        #expect(decoded.requestID == "req-interop")
        #expect(decoded.tool == "MuniAnalyse")

        try? FileManager.default.removeItem(at: tmp)
    }

    @Test
    func buildNotImplementedResult() {
        let request = ToolRequest(requestID: "req-2", tool: "MuniControle", action: "run")
        let result = ToolInteropService.buildNotImplementedResult(for: request, toolVersion: "0.1.0")

        #expect(result.status == .notImplemented)
        #expect(result.errors.first?.code == "NOT_IMPLEMENTED")
        #expect(result.tool == "MuniControle")
    }
}
