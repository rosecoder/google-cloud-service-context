import Foundation
import ServiceContextModule

private enum ServiceVersionKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var serviceVersion: String? {
        get {
            if let serviceVersion = self[ServiceVersionKey.self] {
                return serviceVersion
            }
            let environment = ProcessInfo.processInfo.environment
            return 
                environment["K_REVISION"] ??  // Cloud Run (Service)
                environment["APP_VERSION"] // Fallback
        }
        set {
            self[ServiceVersionKey.self] = newValue
        }
    }
}
