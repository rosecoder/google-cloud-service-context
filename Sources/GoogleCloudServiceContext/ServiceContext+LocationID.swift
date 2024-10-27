import Foundation
import ServiceContextModule

private enum LocationIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var locationID: String? {
        get {
            if let locationID = self[LocationIDKey.self] {
                return locationID
            }
            let environment = ProcessInfo.processInfo.environment
            return 
                environment["GCP_LOCATION_ID"] ??
                environment["GOOGLE_CLOUD_LOCATION"]
        }
        set {
            self[LocationIDKey.self] = newValue
        }
    }
}
