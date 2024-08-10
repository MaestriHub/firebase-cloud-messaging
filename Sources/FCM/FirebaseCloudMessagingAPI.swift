//
//  FirebaseCloudMessagingAPI.swift
//  Created by Vitalii Shevtsov on 8/10/24.
//

import Vapor
@_exported import Core

public extension Application.FirebasePlatform {
    private struct CloudMessagingAPIKey: StorageKey {
        typealias Value = FirebaseCloudMessagingAPI
    }
    
    private struct CloudMessagingConfigurationKey: StorageKey {
        typealias Value = CloudMessagingConfiguration
    }
    
    private struct CloudMessagingHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    var storage: FirebaseCloudMessagingAPI {
        get {
            if let existing = self.application.storage[CloudMessagingAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[CloudMessagingAPIKey.self] = newValue
        }
    }
    
    struct FirebaseCloudMessagingAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        /// A client used to interact with the `FirebaseCloudMessaging` API.
        public var client: CloudMessagingClient {
            do {
                let new = try CloudMessagingClient(
                    credentials: self.application.firebase.credentials,
                    config: self.configuration,
                    httpClient: self.http,
                    eventLoop: self.eventLoop
                )
                return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        /// The configuration for using `FirebaseCloudMessaging` APIs.
        public var configuration: CloudMessagingConfiguration {
            get {
                if let configuration = application.storage[CloudMessagingConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("Cloud storage configuration has not been set. Use app.googleCloud.storage.configuration = ...")
                }
            }
            set {
                if application.storage[CloudMessagingConfigurationKey.self] == nil {
                    application.storage[CloudMessagingConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        public var http: HTTPClient {
            if let existing = application.storage[CloudMessagingHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: CloudMessagingHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[CloudMessagingHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(CloudMessagingHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
}

extension Request {
    private struct FirebaseCloudMessagingKey: StorageKey {
        typealias Value = CloudMessagingClient
    }
    
    /// A client used to interact with the `FirebaseCloudMessaging` API
    public var fcm: CloudMessagingClient {
        if let existing = application.storage[FirebaseCloudMessagingKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let new = Application.FirebasePlatform.FirebaseCloudMessagingAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[FirebaseCloudMessagingKey.self] = new
            return new
        }
    }
}
