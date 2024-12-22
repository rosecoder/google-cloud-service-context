import Foundation
import ServiceContextModule

private enum LocationIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var locationID: String? {
        get async {
            if let locationID = self[LocationIDKey.self] {
                return locationID
            }
            let environment = ProcessInfo.processInfo.environment
            if let locationID = environment["GCP_LOCATION_ID"] ?? environment["GOOGLE_CLOUD_LOCATION"] {
                return locationID
            }
            if let zoneID = await zoneID {
                return String(zoneID.dropLast(2))
            }
            return nil
        }
    }

    public mutating func set(locationID: String?) {
        self[LocationIDKey.self] = locationID
    }
}
