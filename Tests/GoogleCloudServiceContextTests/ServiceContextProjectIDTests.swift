import Testing
import Foundation
@testable import GoogleCloudServiceContext
import ServiceContextModule

@Suite(.serialized) struct ServiceContextProjectIDTests {

    @Test func shouldUseImplicitIfSet() async {
        var context: ServiceContext = .topLevel
        await #expect(context.projectID == nil)

        context.set(projectID: "abc")
        await #expect(context.projectID == "abc")

        context.set(projectID: nil)

        await ProjectIDResolver.shared.resetForTesting()
    }

    @Test(.serialized, arguments: [
        "GCP_PROJECT_ID",
        "GOOGLE_CLOUD_PROJECT",
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) async {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)

        await #expect(ServiceContext.topLevel.projectID == value)

        await ProjectIDResolver.shared.resetForTesting()
        unsetenv(environmentName)
    }

    @Test func shouldUseServiceAccount() async throws {
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("service-account.json")
        try Data(#"{"project_id": "via-service-account"}"#.utf8).write(to: tempFileURL)
        setenv("GOOGLE_APPLICATION_CREDENTIALS", tempFileURL.path, 1)

        await #expect(ServiceContext.topLevel.projectID == "via-service-account")

        await ProjectIDResolver.shared.resetForTesting()
        unsetenv("GOOGLE_APPLICATION_CREDENTIALS")
    }

    @Test func shouldUseResolvedAgain() async {
        let value = "GOOGLE_CLOUD_PROJECT-\(Int.random(in: 0..<100))"
        setenv("GOOGLE_CLOUD_PROJECT", value, 1)

        // First call
        await #expect(ServiceContext.topLevel.projectID == value)

        await #expect(ProjectIDResolver.shared.resolve() == value)

        // Second call – this should be cached call. Can we assert this in someway?
        await #expect(ServiceContext.topLevel.projectID == value)

        await ProjectIDResolver.shared.resetForTesting()
        unsetenv("GOOGLE_CLOUD_PROJECT")
    }
}
