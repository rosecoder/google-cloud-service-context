import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextInstanceIDTests {

    @Test func shouldUseImplicitIfSet() {
        var context = ServiceContext()
        #expect(context.instanceID == nil)

        context.instanceID = "abc"
        #expect(context.instanceID == "abc")
    }

    @Test(arguments: [
        ("KUBERNETES_POD_NAME"),
        ("INSTANCE_ID"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        #expect(ServiceContext.topLevel.instanceID == value)
    }
}
