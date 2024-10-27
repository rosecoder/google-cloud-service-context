import Foundation
import ServiceContextModule

private enum ServiceNameKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var serviceName: String? {
        get {
            if let serviceName = self[ServiceNameKey.self] {
                return serviceName
            }
            let environment = ProcessInfo.processInfo.environment
            return 
                environment["K_SERVICE"] ??  // Cloud Run (Service)
                environment["CLOUD_RUN_JOB"] ??  // Cloud Run (Job)
                environment["KUBERNETES_CONTAINER_NAME"] ?? // Kubernetes
                environment["APP_NAME"] // Fallback

        }
        set {
            self[ServiceNameKey.self] = newValue
        }
    }
}
