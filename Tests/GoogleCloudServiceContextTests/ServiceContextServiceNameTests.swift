import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextServiceNameTests {

    @Test func shouldUseImplicitIfSet() {
        var context = ServiceContext()
        #expect(context.serviceName == nil)

        context.serviceName = "abc"
        #expect(context.serviceName == "abc")
    }

    @Test(arguments: [
        ("K_SERVICE"),
        ("CLOUD_RUN_JOB"),
        ("KUBERNETES_CONTAINER_NAME"),
        ("APP_NAME"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        #expect(ServiceContext.topLevel.serviceName == value)
    }
}
