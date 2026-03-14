import Foundation

public enum ConfigLogLevel: String, Codable, CaseIterable, Sendable {
    case debug
    case info
    case warning
    case error
}

public struct SuiteConfig: Codable, Equatable, Sendable {
    public var environment: String
    public var workspacePath: String?
    public var logLevel: ConfigLogLevel
    public var defaultTimeoutSeconds: Int

    public init(
        environment: String = "dev",
        workspacePath: String? = nil,
        logLevel: ConfigLogLevel = .info,
        defaultTimeoutSeconds: Int = 300
    ) {
        self.environment = environment
        self.workspacePath = workspacePath
        self.logLevel = logLevel
        self.defaultTimeoutSeconds = defaultTimeoutSeconds
    }
}

private struct PartialSuiteConfig: Codable {
    var environment: String?
    var workspacePath: String?
    var logLevel: ConfigLogLevel?
    var defaultTimeoutSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case environment
        case workspacePath = "workspace_path"
        case logLevel = "log_level"
        case defaultTimeoutSeconds = "default_timeout_seconds"
    }
}

public enum SuiteConfigLoader {
    public static func load(
        defaults: SuiteConfig = SuiteConfig(),
        fileURL: URL? = nil,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> SuiteConfig {
        var config = defaults

        if let fileURL {
            let data = try Data(contentsOf: fileURL)
            let partial = try JSONDecoder().decode(PartialSuiteConfig.self, from: data)
            if let value = partial.environment { config.environment = value }
            if let value = partial.workspacePath { config.workspacePath = value }
            if let value = partial.logLevel { config.logLevel = value }
            if let value = partial.defaultTimeoutSeconds { config.defaultTimeoutSeconds = value }
        }

        if let value = environment["ORCHIVISTE_ENVIRONMENT"], !value.isEmpty {
            config.environment = value
        }

        if let value = environment["ORCHIVISTE_WORKSPACE_PATH"], !value.isEmpty {
            config.workspacePath = value
        }

        if let value = environment["ORCHIVISTE_LOG_LEVEL"], let level = ConfigLogLevel(rawValue: value.lowercased()) {
            config.logLevel = level
        }

        if let value = environment["ORCHIVISTE_DEFAULT_TIMEOUT_SECONDS"], let timeout = Int(value), timeout > 0 {
            config.defaultTimeoutSeconds = timeout
        }

        return config
    }
}
