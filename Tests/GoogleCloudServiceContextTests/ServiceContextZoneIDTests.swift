import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextZoneIDTests {

    @Test func shouldUseImplicitIfSet() async {
        var context = ServiceContext()
        await #expect(context.zoneID == nil)

        context.set(zoneID: "abc")
        await #expect(context.zoneID == "abc")
    }

    @Test(arguments: [
        ("GCP_ZONE"),
        ("CLOUD_ZONE"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) async {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        await #expect(ServiceContext.topLevel.zoneID == value)
    }
}
