import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextServiceVersionTests {

    @Test func shouldUseImplicitIfSet() {
        var context = ServiceContext()
        #expect(context.serviceVersion == nil)

        context.serviceVersion = "abc"
        #expect(context.serviceVersion == "abc")
    }

    @Test(arguments: [
        ("K_REVISION"),
        ("APP_VERSION"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        #expect(ServiceContext.topLevel.serviceVersion == value)
    }
}
