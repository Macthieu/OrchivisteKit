import Foundation

public enum LogLevel: String, Codable, CaseIterable, Sendable {
    case debug
    case info
    case warning
    case error
}

public struct LogEvent: Codable, Equatable, Sendable {
    public var timestamp: String
    public var level: LogLevel
    public var message: String
    public var correlationID: String?
    public var requestID: String?
    public var tool: String?
    public var metadata: [String: String]

    public init(
        timestamp: String,
        level: LogLevel,
        message: String,
        correlationID: String? = nil,
        requestID: String? = nil,
        tool: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.correlationID = correlationID
        self.requestID = requestID
        self.tool = tool
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case timestamp
        case level
        case message
        case correlationID = "correlation_id"
        case requestID = "request_id"
        case tool
        case metadata
    }
}

public protocol Logger {
    func log(_ event: LogEvent)
}

public struct ConsoleLogger: Logger {
    public init() {}

    public func log(_ event: LogEvent) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        if let data = try? encoder.encode(event), let line = String(data: data, encoding: .utf8) {
            print(line)
        } else {
            print("{\"level\":\"error\",\"message\":\"failed_to_encode_log_event\"}")
        }
    }
}

public final class InMemoryLogger: Logger {
    public private(set) var events: [LogEvent] = []

    public init() {}

    public func log(_ event: LogEvent) {
        events.append(event)
    }
}
