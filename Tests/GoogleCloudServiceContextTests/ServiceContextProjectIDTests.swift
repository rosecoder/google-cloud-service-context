import Testing
import Foundation
@testable import GoogleCloudServiceContext
import ServiceContextModule

@Suite(.serialized) struct ServiceContextProjectIDTests {

    @Test func shouldUseImplicitIfSet() {
        defer {
            resolved.withLock { $0 = nil }
        }
        
        var context: ServiceContext = .topLevel
        #expect(context.projectID == nil)

        context.projectID = "abc"
        #expect(context.projectID == "abc")

        context.projectID = nil
    }

    @Test(.serialized, arguments: [
        "GCP_PROJECT_ID",
        "GOOGLE_CLOUD_PROJECT",
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) {
        defer {
            resolved.withLock { $0 = nil }
            unsetenv(environmentName)
        }

        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)

        #expect(ServiceContext.topLevel.projectID == value)
    }

    @Test func shouldUseServiceAccount() throws {
        defer {
            resolved.withLock { $0 = nil }
            unsetenv("GOOGLE_APPLICATION_CREDENTIALS") 
        }

        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("service-account.json")
        try Data(#"{"project_id": "via-service-account"}"#.utf8).write(to: tempFileURL)
        setenv("GOOGLE_APPLICATION_CREDENTIALS", tempFileURL.path, 1)

        #expect(ServiceContext.topLevel.projectID == "via-service-account")
    }

    @Test func shouldUseResolvedAgain() {
        defer {
            resolved.withLock { $0 = nil }
        }

        let value = "GOOGLE_CLOUD_PROJECT-\(Int.random(in: 0..<100))"
        setenv("GOOGLE_CLOUD_PROJECT", value, 1)

        // First call
        #expect(ServiceContext.topLevel.projectID == value)

        resolved.withLock { cached in
            #expect(cached == value)
        }

        // Second call – this should be cached call. Can we assert this in someway?
        #expect(ServiceContext.topLevel.projectID == value)
    }
}
