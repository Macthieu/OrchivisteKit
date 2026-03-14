import Foundation

public enum ContractSchemaVersion: String, Codable, CaseIterable, Sendable {
    case v1_0 = "1.0"
}

public enum ToolStatus: String, Codable, CaseIterable, Sendable {
    case queued
    case running
    case succeeded
    case failed
    case needsReview = "needs_review"
    case cancelled
    case notImplemented = "not_implemented"
}

public enum ArtifactKind: String, Codable, CaseIterable, Sendable {
    case input
    case output
    case intermediate
    case report
    case log
    case metadata
    case other
}

public enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public struct ArtifactDescriptor: Codable, Equatable, Sendable {
    public var id: String
    public var kind: ArtifactKind
    public var uri: String
    public var mediaType: String?
    public var checksum: String?
    public var sizeBytes: Int?
    public var metadata: [String: JSONValue]

    public init(
        id: String,
        kind: ArtifactKind,
        uri: String,
        mediaType: String? = nil,
        checksum: String? = nil,
        sizeBytes: Int? = nil,
        metadata: [String: JSONValue] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.uri = uri
        self.mediaType = mediaType
        self.checksum = checksum
        self.sizeBytes = sizeBytes
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case uri
        case mediaType = "media_type"
        case checksum
        case sizeBytes = "size_bytes"
        case metadata
    }
}

public struct ToolError: Codable, Equatable, Sendable {
    public var code: String
    public var message: String
    public var details: [String: JSONValue]
    public var retryable: Bool

    public init(
        code: String,
        message: String,
        details: [String: JSONValue] = [:],
        retryable: Bool = false
    ) {
        self.code = code
        self.message = message
        self.details = details
        self.retryable = retryable
    }
}

public struct ToolRequest: Codable, Equatable, Sendable {
    public var schemaVersion: ContractSchemaVersion
    public var requestID: String
    public var correlationID: String?
    public var tool: String
    public var action: String
    public var workspacePath: String?
    public var inputArtifacts: [ArtifactDescriptor]
    public var parameters: [String: JSONValue]
    public var requestedAt: String?

    public init(
        schemaVersion: ContractSchemaVersion = .v1_0,
        requestID: String,
        correlationID: String? = nil,
        tool: String,
        action: String,
        workspacePath: String? = nil,
        inputArtifacts: [ArtifactDescriptor] = [],
        parameters: [String: JSONValue] = [:],
        requestedAt: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.requestID = requestID
        self.correlationID = correlationID
        self.tool = tool
        self.action = action
        self.workspacePath = workspacePath
        self.inputArtifacts = inputArtifacts
        self.parameters = parameters
        self.requestedAt = requestedAt
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case requestID = "request_id"
        case correlationID = "correlation_id"
        case tool
        case action
        case workspacePath = "workspace_path"
        case inputArtifacts = "input_artifacts"
        case parameters
        case requestedAt = "requested_at"
    }
}

public struct ProgressEvent: Codable, Equatable, Sendable {
    public var requestID: String
    public var status: ToolStatus
    public var stage: String
    public var percent: Int?
    public var message: String?
    public var occurredAt: String
    public var metadata: [String: JSONValue]

    public init(
        requestID: String,
        status: ToolStatus,
        stage: String,
        percent: Int? = nil,
        message: String? = nil,
        occurredAt: String,
        metadata: [String: JSONValue] = [:]
    ) {
        self.requestID = requestID
        self.status = status
        self.stage = stage
        self.percent = percent
        self.message = message
        self.occurredAt = occurredAt
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case status
        case stage
        case percent
        case message
        case occurredAt = "occurred_at"
        case metadata
    }
}

public struct ToolResult: Codable, Equatable, Sendable {
    public var schemaVersion: ContractSchemaVersion
    public var requestID: String
    public var tool: String
    public var status: ToolStatus
    public var startedAt: String?
    public var finishedAt: String?
    public var progressEvents: [ProgressEvent]
    public var outputArtifacts: [ArtifactDescriptor]
    public var errors: [ToolError]
    public var summary: String?
    public var metadata: [String: JSONValue]

    public init(
        schemaVersion: ContractSchemaVersion = .v1_0,
        requestID: String,
        tool: String,
        status: ToolStatus,
        startedAt: String? = nil,
        finishedAt: String? = nil,
        progressEvents: [ProgressEvent] = [],
        outputArtifacts: [ArtifactDescriptor] = [],
        errors: [ToolError] = [],
        summary: String? = nil,
        metadata: [String: JSONValue] = [:]
    ) {
        self.schemaVersion = schemaVersion
        self.requestID = requestID
        self.tool = tool
        self.status = status
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.progressEvents = progressEvents
        self.outputArtifacts = outputArtifacts
        self.errors = errors
        self.summary = summary
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case requestID = "request_id"
        case tool
        case status
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case progressEvents = "progress_events"
        case outputArtifacts = "output_artifacts"
        case errors
        case summary
        case metadata
    }
}
