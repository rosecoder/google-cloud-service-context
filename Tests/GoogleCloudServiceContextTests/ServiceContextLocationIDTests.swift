import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextLocationIDTests {

    @Test func shouldUseImplicitIfSet() async {
        var context = ServiceContext()
        await #expect(context.locationID == nil)

        context.set(locationID: "abc")
        await #expect(context.locationID == "abc")
    }

    @Test(arguments: [
        ("GCP_LOCATION_ID"),
        ("GOOGLE_CLOUD_LOCATION"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) async {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        await #expect(ServiceContext.topLevel.locationID == value)
    }
}
