import Foundation
import ServiceContextModule

private enum InstanceIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var instanceID: String? {
        get async {
            if let instanceID = self[InstanceIDKey.self] {
                return instanceID
            }
            let environment = ProcessInfo.processInfo.environment
            if let instanceID = environment["KUBERNETES_POD_NAME"] ?? environment["INSTANCE_ID"] ?? environment["GCP_INSTANCE"] ?? environment["CLOUD_INSTANCE"] {
                return instanceID
            }
            if let resolver = GoogleServiceContextResolver.shared {
                return try? await resolver.fetchFromMetadataServer(resource: "instance/id")
            }
            return nil
        }
    }

    public mutating func set(instanceID: String?) {
        self[InstanceIDKey.self] = instanceID
    }
}
