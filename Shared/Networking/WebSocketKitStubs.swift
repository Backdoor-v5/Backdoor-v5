// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import Foundation

/// This file contains stub implementations for WebSocketKit dependencies
/// It allows the app to compile even when WebSocketKit is not available
/// For production use, replace this with the actual WebSocketKit implementation

// MARK: - WebSocketKit Stubs

/// WebSocketClient stub
public struct WebSocketClient {
    /// Configuration for WebSocketClient
    public struct Configuration {
        public var tlsConfiguration: TLSConfiguration?
        public var maxFrameSize: Int = 1 << 14
        
        public init(tlsConfiguration: TLSConfiguration? = nil, maxFrameSize: Int = 1 << 14) {
            self.tlsConfiguration = tlsConfiguration
            self.maxFrameSize = maxFrameSize
        }
    }
    
    /// Connect to a WebSocket server - stub implementation
    public static func connect(
        to url: String,
        headers: [(String, String)] = [],
        configuration: Configuration = .init(),
        on eventLoopGroup: EventLoopGroup
    ) -> EventLoopFuture<WebSocket> {
        Debug.shared.log(message: "WebSocketKit connect called (stub)", type: .warning)
        return EventLoopFuture<WebSocket>.makeSucceeded(WebSocket(), on: eventLoopGroup)
    }
}

/// WebSocket stub
public final class WebSocket {
    /// Various callbacks for WebSocket events
    public var onText: (WebSocket, String) -> Void = { _, _ in }
    public var onBinary: (WebSocket, [UInt8]) -> Void = { _, _ in }
    public var onError: (WebSocket, Error) -> Void = { _, _ in }
    public var onClose: (WebSocket) -> Void = { _ in }
    
    /// Send text - stub implementation
    public func send(_ text: String) {
        Debug.shared.log(message: "WebSocket send text: \(text) (stub)", type: .info)
    }
    
    /// Send binary data - stub implementation
    public func send<Data: Collection>(_ binary: Data) where Data.Element == UInt8 {
        Debug.shared.log(message: "WebSocket send binary data (stub)", type: .info)
    }
    
    /// Close the WebSocket - stub implementation
    public func close() {
        Debug.shared.log(message: "WebSocket close called (stub)", type: .info)
    }
}

/// EventLoopGroup stub
public protocol EventLoopGroup {
    /// Creates a succeeded future - stub implementation
    func makeSucceededFuture<T>(_ value: T) -> EventLoopFuture<T>
}

/// EventLoopFuture stub
public class EventLoopFuture<T> {
    /// Creates a succeeded future - stub implementation
    static func makeSucceeded(_ value: T, on group: EventLoopGroup) -> EventLoopFuture<T> {
        return EventLoopFuture(value: value)
    }
    
    private let value: T
    
    init(value: T) {
        self.value = value
    }
}

/// TLS Configuration stub if not already defined
#if !canImport(NIOSSL)
public struct TLSConfiguration {
    public static func forClient() -> TLSConfiguration {
        return TLSConfiguration()
    }
}
#endif
