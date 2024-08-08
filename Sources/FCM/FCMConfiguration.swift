import Foundation
import Vapor

public struct FCMConfiguration {
    let email, projectId, key: String
    let serverKey, senderId: String?
    
    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig<FCMApnsPayload>?
    public var androidDefaultConfig: FCMAndroidConfig?
    public var webpushDefaultConfig: FCMWebpushConfig?
    
    // MARK: Initializers
    
    public init(email: String, projectId: String, key: String, serverKey: String? = nil, senderId: String? = nil) {
        self.email = email
        self.projectId = projectId
        self.key = key
        self.serverKey = serverKey ?? Environment.get("FCM_SERVER_KEY")
        self.senderId = senderId ?? Environment.get("FCM_SENDER_ID")
    }
    
    public init(fromJSON json: String) {
        let s = Self.parseServiceAccount(from: json)
        self.email = s.client_email
        self.projectId = s.project_id
        self.key = s.private_key
        self.serverKey = s.server_key ?? Environment.get("FCM_SERVER_KEY")
        self.senderId = s.sender_id ?? Environment.get("FCM_SENDER_ID")
    }
    
    // MARK: Static initializers
    
    /// It will try to read path to service account key from environment variables
    public static var envServiceAccountKey: FCMConfiguration {
        if let jsonString = Environment.get("GOOGLE_APPLICATION_CREDENTIALS") {
            return .init(fromJSON: jsonString)
        } else {
            fatalError("FCM envServiceAccountKey not set")
        }
    }
    
    // MARK: Helpers
    
    private struct ServiceAccount: Codable {
        let project_id, private_key, client_email: String
        let server_key, sender_id: String?
    }
    
    private static func parseServiceAccount(from json: String) -> ServiceAccount {
        guard let data = json.data(using: .utf8),
              let serviceAccount = try? JSONDecoder().decode(ServiceAccount.self, from: data) else {
            fatalError("FCM unable to decode serviceAccount from json string: \(json)")
        }
        return serviceAccount
    }
}
