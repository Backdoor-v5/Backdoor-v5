// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import Foundation

/// This file contains stub implementations for NIOHTTP2 dependencies
/// It allows the app to compile even when NIOHTTP2 is not available
/// For production use, replace this with the actual NIOHTTP2 implementation

// MARK: - NIOHTTP2 Stubs

/// HTTP2 error type stub
public enum HTTP2Error: Error {
    case streamClosed
    case invalidFlowControlWindowSize
    case badClientMagic
    case receivedBadSettings
    case invalidFramePayloadLength
    case excessiveResetFrames
    case tooManyPings
    case invalidWindowUpdateValue
    case continuationFrameOnWrongStream
    case missingPreface
    case excessiveEmptyDataFrames
    case receivedFrameWhileIdle
    case dataOnStreamZero
    case headersOnStreamZero
    case priorityOnStreamZero
    case rstStreamOnStreamZero
    case pushPromiseOnStreamZero
    case windowUpdateOnStreamZero
    
    public var description: String {
        switch self {
        case .streamClosed:
            return "HTTP/2 stream closed"
        case .invalidFlowControlWindowSize:
            return "Invalid flow control window size"
        default:
            return "HTTP/2 protocol error"
        }
    }
}

/// HTTP2 Stream State stub
public enum HTTP2StreamState {
    case idle
    case reservedRemote
    case reservedLocal
    case open
    case halfClosedRemote
    case halfClosedLocal
    case closed
}

/// HTTP2 Frame Type stub 
public enum HTTP2FrameType: UInt8 {
    case data = 0x0
    case headers = 0x1
    case priority = 0x2
    case rstStream = 0x3
    case settings = 0x4
    case pushPromise = 0x5
    case ping = 0x6
    case goAway = 0x7
    case windowUpdate = 0x8
    case continuation = 0x9
    
    public var description: String {
        switch self {
        case .data:
            return "DATA"
        case .headers:
            return "HEADERS"
        case .priority:
            return "PRIORITY"
        case .rstStream:
            return "RST_STREAM"
        case .settings:
            return "SETTINGS"
        case .pushPromise:
            return "PUSH_PROMISE"
        case .ping:
            return "PING"
        case .goAway:
            return "GOAWAY"
        case .windowUpdate:
            return "WINDOW_UPDATE"
        case .continuation:
            return "CONTINUATION"
        }
    }
}

/// HTTP2 Connection State Machine stub
public class ConnectionStateMachine {
    public init() {
        Debug.shared.log(message: "NIOHTTP2 ConnectionStateMachine initialized (stub)", type: .debug)
    }
}

/// HTTP2 Connection Streams State stub
public class ConnectionStreamsState {
    public init() {
        Debug.shared.log(message: "NIOHTTP2 ConnectionStreamsState initialized (stub)", type: .debug)
    }
}

/// HTTP2 MayReceiveFrames Protocol stub
public protocol MayReceiveFrames {
    var connectionState: ConnectionStateMachine { get }
    var streamState: ConnectionStreamsState { get }
}

/// HTTP2 Receiving States stubs
public class ReceivingDataState: MayReceiveFrames {
    public var connectionState: ConnectionStateMachine
    public var streamState: ConnectionStreamsState
    
    public init() {
        self.connectionState = ConnectionStateMachine()
        self.streamState = ConnectionStreamsState()
    }
}

public class ReceivingGoAwayState: MayReceiveFrames {
    public var connectionState: ConnectionStateMachine
    public var streamState: ConnectionStreamsState
    
    public init() {
        self.connectionState = ConnectionStateMachine()
        self.streamState = ConnectionStreamsState()
    }
}

public class ReceivingHeadersState: MayReceiveFrames {
    public var connectionState: ConnectionStateMachine
    public var streamState: ConnectionStreamsState
    
    public init() {
        self.connectionState = ConnectionStateMachine()
        self.streamState = ConnectionStreamsState()
    }
}

public class ReceivingPushPromiseState: MayReceiveFrames {
    public var connectionState: ConnectionStateMachine
    public var streamState: ConnectionStreamsState
    
    public init() {
        self.connectionState = ConnectionStateMachine()
        self.streamState = ConnectionStreamsState()
    }
}

public class ReceivingRstStreamState: MayReceiveFrames {
    public var connectionState: ConnectionStateMachine
    public var streamState: ConnectionStreamsState
    
    public init() {
        self.connectionState = ConnectionStateMachine()
        self.streamState = ConnectionStreamsState()
    }
}
