import Foundation
import Synchronization
import ServiceContextModule

private enum ProjectIDKey: ServiceContextKey {

    typealias Value = String
}

extension ServiceContext {

    /// The Google Cloud project ID associated with this service context.
    ///
    /// This property provides access to the Google Cloud project ID, which is a unique identifier
    /// for a Google Cloud project. The project ID is resolved using the following methods, in order:
    ///
    /// 1. If explicitly set, the stored value is returned.
    /// 2. If not set, it attempts to resolve from the environment variable `GOOGLE_CLOUD_PROJECT`.
    /// 3. If not found in the environment, it tries to resolve from the service account credentials file.
    ///
    /// The resolved value is cached for subsequent accesses to improve performance.
    ///
    /// - Returns: The Google Cloud project ID as a `String`, or `nil` if it couldn't be resolved.
    public var projectID: String? {
        get {
            if let projectID = self[ProjectIDKey.self] {
                return projectID
            }
            return resolved.withLock {
                if let projectID = $0 {
                    return projectID
                }
                let projectID = resolve()
                $0 = projectID
                return projectID
            }
        }
        set {
            self[ProjectIDKey.self] = newValue
        }
    }
}

let resolved = Mutex<String??>(nil)

private func resolve() -> String? {
    if let result = resolveViaEnvironment() {
        return result
    }
    if let result = resolveViaServiceAccount() {
        return result
    }
    return nil
}

private func resolveViaEnvironment() -> String? {
    let environment = ProcessInfo.processInfo.environment
    return environment["GCP_PROJECT_ID"] ?? 
           environment["GOOGLE_CLOUD_PROJECT"]
}

private func resolveViaServiceAccount() -> String? {

    struct ServiceAccount: Decodable {

        let projectID: String

        enum CodingKeys: String, CodingKey {
            case projectID = "project_id"
        }
    }

    guard
        let path = ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"],
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let serviceAccount = try? JSONDecoder().decode(ServiceAccount.self, from: data)        
    else {
        return nil
    }
    return serviceAccount.projectID
}
