import Testing
import Foundation
@testable import GoogleCloudServiceContext
@testable import ServiceContextModule

@Suite(.serialized) struct ServiceContextInstanceIDTests {

    @Test func shouldUseImplicitIfSet() async {
        var context = ServiceContext()
        await #expect(context.instanceID == nil)

        context.set(instanceID: "abc")
        await #expect(context.instanceID == "abc")
    }

    @Test(arguments: [
        ("KUBERNETES_POD_NAME"),
        ("INSTANCE_ID"),
    ]) func shouldUseEnvironmentVariableIfSet(environmentName: String) async {
        let value = "\(environmentName)-\(Int.random(in: 0..<100))"
        setenv(environmentName, value, 1)
        defer { unsetenv(environmentName) }

        await #expect(ServiceContext.topLevel.instanceID == value)
    }
}
