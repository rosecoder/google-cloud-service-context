import ServiceLifecycle
import RetryableTask
import Synchronization
import AsyncHTTPClient
import Logging

public actor GoogleServiceContextResolver: Service {

    private let logger = Logger(label: "GoogleServiceContextResolver")

    public let endpoint: String

    public init(endpoint: String = "http://metadata.google.internal") {
        self.endpoint = endpoint

        Self._shared.withLock { 
            precondition($0 == nil, "GoogleServiceContextResolver must only be initialized once")
            $0 = self
        }
    }

    private static let _shared = Mutex<GoogleServiceContextResolver?>(nil)

    public static var shared: GoogleServiceContextResolver? {
        _shared.withLock { $0 }
    }

    let client = HTTPClient(eventLoopGroupProvider: .shared(.singletonMultiThreadedEventLoopGroup))

    public func run() async throws {
        await cancelWhenGracefulShutdown {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: .max / 2)
            }
        }
        try await client.shutdown()
    }

    public typealias Resource = String

    private var fetchTasks: [Resource: Task<String, Error>] = [:]

    public func fetchFromMetadataServer(resource: Resource) async throws -> String {
        if let task = fetchTasks[resource] {
            return try await task.value
        }
        let task = Task {
            try await fetchFromMetadataServerUncached(resource: resource)
        }
        fetchTasks[resource] = task
        do {
            return try await task.value
        } catch {
            fetchTasks[resource] = nil
            throw error
        }
    }

    private nonisolated func fetchFromMetadataServerUncached(resource: Resource) async throws -> String {
        var request = HTTPClientRequest(url: endpoint + "/computeMetadata/v1/" + resource)
        request.method = .GET
        request.headers.add(name: "Metadata-Flavor", value: "Google")

        return try await withRetryableTask(logger: logger) {
            let response = try await client.execute(request, timeout: .seconds(1))
            let body = try await response.body.collect(upTo: 1024) // 1KB
            return String(buffer: body)
        }
    }
}
