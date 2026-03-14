import Testing
@testable import OrchivisteKitConfig

struct ConfigTests {
    @Test
    func loadWithEnvironmentOverrides() throws {
        let defaults = SuiteConfig(environment: "dev", workspacePath: nil, logLevel: .info, defaultTimeoutSeconds: 300)
        let env: [String: String] = [
            "ORCHIVISTE_ENVIRONMENT": "ci",
            "ORCHIVISTE_WORKSPACE_PATH": "/tmp/ws",
            "ORCHIVISTE_LOG_LEVEL": "error",
            "ORCHIVISTE_DEFAULT_TIMEOUT_SECONDS": "120"
        ]

        let config = try SuiteConfigLoader.load(defaults: defaults, environment: env)

        #expect(config.environment == "ci")
        #expect(config.workspacePath == "/tmp/ws")
        #expect(config.logLevel == .error)
        #expect(config.defaultTimeoutSeconds == 120)
    }
}
