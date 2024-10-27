import Foundation
import ServiceContextModule

private enum InstanceIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var instanceID: String? {
        get {
            if let instanceID = self[InstanceIDKey.self] {
                return instanceID
            }
            let environment = ProcessInfo.processInfo.environment
            return 
                environment["KUBERNETES_POD_NAME"] ?? // Kubernetes
                environment["INSTANCE_ID"] // Fallback
        }
        set {
            self[InstanceIDKey.self] = newValue
        }
    }
}
