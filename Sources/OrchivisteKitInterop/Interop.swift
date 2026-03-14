import Foundation
import OrchivisteKitContracts
import OrchivisteKitObservability

public enum InteropError: Error {
    case requestDecodeFailed(String)
    case resultEncodeFailed(String)
}

public enum JSONFileCodec {
    public static func decode<T: Decodable>(_ type: T.Type, from fileURL: URL) throws -> T {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw InteropError.requestDecodeFailed(error.localizedDescription)
        }
    }

    public static func encode<T: Encodable>(_ value: T, to fileURL: URL) throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(value)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw InteropError.resultEncodeFailed(error.localizedDescription)
        }
    }
}

public enum ToolInteropService {
    public static func loadRequest(from fileURL: URL) throws -> ToolRequest {
        try JSONFileCodec.decode(ToolRequest.self, from: fileURL)
    }

    public static func writeResult(_ result: ToolResult, to fileURL: URL) throws {
        try JSONFileCodec.encode(result, to: fileURL)
    }

    public static func buildNotImplementedResult(
        for request: ToolRequest,
        toolVersion: String,
        logger: Logger? = nil
    ) -> ToolResult {
        let now = ISO8601DateFormatter().string(from: Date())
        let error = ToolError(
            code: "NOT_IMPLEMENTED",
            message: "Tool scaffold is available but business logic is not implemented yet.",
            details: ["tool_version": .string(toolVersion)],
            retryable: false
        )

        let progress = ProgressEvent(
            requestID: request.requestID,
            status: .notImplemented,
            stage: "bootstrap",
            percent: 100,
            message: "Execution reached scaffold boundary.",
            occurredAt: now
        )

        let result = ToolResult(
            requestID: request.requestID,
            tool: request.tool,
            status: .notImplemented,
            startedAt: now,
            finishedAt: now,
            progressEvents: [progress],
            outputArtifacts: [],
            errors: [error],
            summary: "Tool is scaffolded and wired for CLI JSON integration.",
            metadata: ["tool_version": .string(toolVersion)]
        )

        logger?.log(
            LogEvent(
                timestamp: now,
                level: .warning,
                message: "not_implemented result emitted",
                correlationID: request.correlationID,
                requestID: request.requestID,
                tool: request.tool,
                metadata: ["tool_version": toolVersion]
            )
        )

        return result
    }
}
