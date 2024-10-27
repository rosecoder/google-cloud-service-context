import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextLocationIDTests {

    @Test func shouldUseImplicitIfSet() {
        var context = ServiceContext()
        #expect(context.locationID == nil)

        context.locationID = "abc"
        #expect(context.locationID == "abc")
    }

    @Test(arguments: [
        ("GCP_LOCATION_ID"),
        ("GOOGLE_CLOUD_LOCATION"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        #expect(ServiceContext.topLevel.locationID == value)
    }
}
