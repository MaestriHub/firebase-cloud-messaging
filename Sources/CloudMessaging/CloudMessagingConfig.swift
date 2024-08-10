import Core
import Foundation

public struct CloudMessagingConfiguration: GoogleCloudAPIConfiguration {
    
    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig?
    public var androidDefaultConfig: FCMAndroidConfig?
    public var webpushDefaultConfig: FCMWebpushConfig?
    
    //TODO: Может быть стоит добавить senderID
    
    public var scope: [GoogleCloudAPIScope]
    public let serviceAccount: String
    public let project: String?
    public let subscription: String? = nil
    
    public init(scope: [GoogleCloudStorageScope], serviceAccount: String, project: String?) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }
    
    public static func `default`() -> FCMConfiguration {
        return FCMConfiguration(
            scope: [.cloudPlatform],
            serviceAccount: "default",
            project: nil
        )
    }
}

public enum FirebaseCloudMessagingScope: GoogleCloudAPIScope {
    /// View and manage your data across Google Cloud Platform services
    case cloudPlatform
    
    public var value: String {
        switch self {
        case .cloudPlatform: return "https://www.googleapis.com/auth/cloud-platform"
        }
    }
}
