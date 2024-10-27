import Foundation
import ServiceContextModule

private enum TraceKey: ServiceContextKey {

    typealias Value = Trace
}

/// Represents a trace in Google Cloud.
///
/// See more: https://cloud.google.com/trace/docs/trace-context
public struct Trace: Sendable {

    /// The unique identifier of the end-to-end operation in which this particular overall operation took place. The value of this field is provided by the parent.
    public let id: UInt128

    /// A unique identifier for the child operation. If the same operation is executed multiple times, then there are multiple spans for that operation, each with a unique identifier.
    public var spanIDs: [UInt64]

    /// Whether the trace is sampled.
    public let isSampled: Bool

    public init(id: UInt128, spanIDs: [UInt64], isSampled: Bool) {
        self.id = id
        self.spanIDs = spanIDs
        self.isSampled = isSampled
    }
}

extension ServiceContext {

    public var trace: Trace? {
        get { self[TraceKey.self] }
        set { self[TraceKey.self] = newValue }
    }
}
