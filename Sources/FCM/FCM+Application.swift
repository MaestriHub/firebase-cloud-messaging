import Vapor
@_exported import Core

public extension Application {
    var firebase: Application.FirebasePlatform {
        .init(application: self)
    }
    
    private struct CloudCredentialsKey: StorageKey {
        typealias Value = GoogleCloudCredentialsConfiguration
    }
    
    struct FirebasePlatform {
        public let application: Application
        
        /// The configuration for authentincating to GCP APIs via credentials
        public var credentials: GoogleCloudCredentialsConfiguration {
            get {
                if let credentials = application.storage[CloudCredentialsKey.self] {
                   return credentials
                } else {
                    fatalError("Cloud credentials configuration has not been set. Use app.googleCloud.credentials = ...")
                }
            }
            nonmutating set {
                if application.storage[CloudCredentialsKey.self] == nil {
                   application.storage[CloudCredentialsKey.self] = newValue
                } else {
                    fatalError("Overriding credentials configuration after being set is not allowed.")
                }
            }
        }
    }
}
