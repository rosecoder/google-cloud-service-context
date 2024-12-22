import Foundation
import ServiceContextModule

private enum ZoneIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    public var zoneID: String? {
        get async {
            if let zoneID = self[ZoneIDKey.self] {
                return zoneID
            }
            let environment = ProcessInfo.processInfo.environment
            if let zoneID = environment["GCP_ZONE"] ?? environment["CLOUD_ZONE"] {
                return zoneID
            }
            if let resolver = GoogleServiceContextResolver.shared {
                let projectAndZoneID = try? await resolver.fetchFromMetadataServer(resource: "instance/zone") // format: "projects/1234567890/zones/us-central1-a"
                return projectAndZoneID?.split(separator: "/").last.map(String.init)
            }
            return nil
        }
    }

    public mutating func set(zoneID: String) {
        self[ZoneIDKey.self] = zoneID
    }
}
