import Testing
import NIO
import NIOHTTP1
import RetryableTask
@testable import GoogleCloudServiceContext

private let port = 59290 // a random ephemeral port
private let resolver = GoogleServiceContextResolver(endpoint: "http://127.0.0.1:\(port)")

@Suite(.serialized) struct GoogleServiceContextResolverTests {

    init() async {
        await DefaultRetryPolicyConfiguration.shared.use(retryPolicy: NoRetryPolicy())
    }

    @Test func shouldFailIfNoMetadataServer() async throws {
        await #expect(throws: Error.self) {
            _ = try await resolver.fetchFromMetadataServer(resource: "project/project-id")
        }
    }

    @Test func shouldResolve() async throws {
        let mockServer = try await startMockMetadataServer(resources: [
            "project/project-id": "test-project-id",
            "project/numeric-id": "1234567890",
            "project/name": "test-project",
            "project/attributes/name": "test-project",
            "project/attributes/numeric-id": "1234567890",
            "instance/zone": "projects/1234567890/zones/europe-west3-c",
            "instance/id": "123",
        ])

        let projectID = try await resolver.fetchFromMetadataServer(resource: "project/project-id")
        #expect(projectID == "test-project-id")

        let projectID2 = try await resolver.fetchFromMetadataServer(resource: "project/project-id")
        #expect(projectID2 == "test-project-id")

        let projectName = try await resolver.fetchFromMetadataServer(resource: "project/name")
        #expect(projectName == "test-project")

        await #expect(ServiceContext.topLevel.zoneID == "europe-west3-c")
        await #expect(ServiceContext.topLevel.locationID == "europe-west3")
        await #expect(ServiceContext.topLevel.instanceID == "123")
        await #expect(ServiceContext.topLevel.projectID == "test-project-id")

        try await mockServer.shutdown()
    }

    private struct MockMetadataServer {

        let shutdown: () async throws -> Void
    }

    private func startMockMetadataServer(resources: [String: String]) async throws -> MockMetadataServer {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let bootstrap = ServerBootstrap(group: eventLoopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler(resources: resources))
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

        let channel = try await bootstrap.bind(host: "127.0.0.1", port: port).get()

        return MockMetadataServer(shutdown: {
            try await channel.close()
            try await eventLoopGroup.shutdownGracefully()
        })
    }

    final class HTTPHandler: ChannelInboundHandler {

        let resources: [String: String]

        init(resources: [String: String]) {
            self.resources = resources
        }

        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let part = self.unwrapInboundIn(data)
            switch part {
            case .head(let inboundHead):
                guard inboundHead.headers["Metadata-Flavor"] == ["Google"] else {
                    context.write(self.wrapOutboundOut(.head(HTTPResponseHead(
                        version: .http1_1,
                        status: .forbidden,
                        headers: HTTPHeaders([("Content-Type", "text/html")])
                    ))), promise: nil)
                    context.write(self.wrapOutboundOut(.body(.byteBuffer(ByteBuffer(
                        string: "Error 403 (Forbidden)!!1"
                    )))), promise: nil)
                    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                    return
                }
                guard let resource = resources.first(where: { inboundHead.uri.hasSuffix($0.key) }) else {
                    context.write(self.wrapOutboundOut(.head(HTTPResponseHead(
                        version: .http1_1,
                        status: .notFound,
                        headers: HTTPHeaders([("Content-Type", "text/html")])
                    ))), promise: nil)
                    context.write(self.wrapOutboundOut(.body(.byteBuffer(ByteBuffer(
                        string: "Error 404 (Not Found)!!1"
                    )))), promise: nil)
                    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
                    return
                }

                let responseHead = HTTPResponseHead(
                    version: .http1_1,
                    status: .ok,
                    headers: HTTPHeaders([("Content-Type", "text/plain")])
                )
                context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
                context.write(self.wrapOutboundOut(.body(.byteBuffer(ByteBuffer(
                    string: resource.value
                )))), promise: nil)
                context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
            case .body, .end:
                break
            }
        }

        func errorCaught(context: ChannelHandlerContext, error: Error) {
            print("Error: \(error)")
            context.close(promise: nil)
        }
    }
}
