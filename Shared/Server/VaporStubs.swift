// Proprietary Software License Version 1.0
//
// Copyright (C) 2025 BDG
//
// Backdoor App Signer is proprietary software. You may not use, modify, or distribute it except as expressly permitted under the terms of the Proprietary Software License.

import Foundation
import NIOSSL

/// This file contains stub implementations for Vapor dependencies
/// It allows the app to compile even when Vapor is not available
/// For production use, replace this with the actual Vapor implementation

// MARK: - Vapor Stub Implementation

/// Stubbed Vapor namespace
enum Vapor {
    /// Stub for Vapor's Application class
    class Application {
        var http: HTTPStub
        var middleware: MiddlewareStub
        var sessions: SessionsStub
        var views: ViewsStub
        var routes: RoutesStub
        
        init() {
            self.http = HTTPStub()
            self.middleware = MiddlewareStub()
            self.sessions = SessionsStub()
            self.views = ViewsStub()
            self.routes = RoutesStub()
        }
        
        func shutdown() {
            // Stub for shutdown
            Debug.shared.log(message: "Vapor application shutdown called (stub)", type: .info)
        }
    }
    
    /// Simple HTTP client stub
    class HTTPStub {
        var server: ServerStub
        
        init() {
            self.server = ServerStub()
        }
    }
    
    /// Server configuration stub
    class ServerStub {
        var configuration: Configuration
        
        init() {
            self.configuration = Configuration()
        }
        
        class Configuration {
            var hostname: String = "localhost"
            var port: Int = 8080
            var address: String { "\(hostname):\(port)" }
            
            var tlsConfiguration: TLSConfiguration?
        }
    }
    
    /// Middleware stub
    class MiddlewareStub {
        var use: (Any) -> Void = { _ in }
    }
    
    /// Sessions stub
    class SessionsStub {
        var configuration = SessionConfiguration()
        
        struct SessionConfiguration {
            var cookieName: String = "vapor_session"
            var cookie = CookieStub()
        }
        
        struct CookieStub {
            var isSecure: Bool = false
        }
    }
    
    /// Views stub
    class ViewsStub {
        func register(_ renderer: Any) {
            // Stub for registering view renderers
        }
    }
    
    /// Routes stub
    class RoutesStub {
        func get(_ path: String, use: @escaping () -> String) {
            // Stub for GET route
            Debug.shared.log(message: "Registered GET route: \(path) (stub)", type: .info)
        }
        
        func post(_ path: String, use: @escaping () -> String) {
            // Stub for POST route
            Debug.shared.log(message: "Registered POST route: \(path) (stub)", type: .info)
        }
    }
    
    /// Empty protocol for compatibility
    protocol RouteCollection {
        // Empty protocol for compatibility
    }
}

// Stub for Leaf template renderer
class LeafStub {
    class Renderer {
        // Stub implementation
    }
}

// Return types for common operations
extension Vapor {
    typealias Request = Any
    typealias Response = Any
    typealias EventLoop = Any
}

// Stub for NIOSSL.TLSConfiguration
extension TLSConfiguration {
    static var makeServerConfiguration: TLSConfiguration {
        return TLSConfiguration(
            certificateChain: [],
            privateKey: .file(""),
            certificateVerification: .none
        )
    }
}
