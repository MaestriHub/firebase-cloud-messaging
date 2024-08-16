import Foundation
import Vapor

public struct FCMConfiguration {
    let email, projectId, key: String
    
    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig?
    public var androidDefaultConfig: FCMAndroidConfig?
    public var webpushDefaultConfig: FCMWebpushConfig?
    
    // MARK: Initializers
    
    public init(fromJSON json: String) {
        struct ServiceAccount: Codable {
            let project_id, private_key, client_email: String
            let server_key, sender_id: String?
        }
        guard let data = json.data(using: .utf8),
              let serviceAccount = try? JSONDecoder().decode(ServiceAccount.self, from: data) else {
            fatalError("FCM unable to decode serviceAccount from json string: \(json)")
        }
        self.email = serviceAccount.client_email
        self.projectId = serviceAccount.project_id
        self.key = serviceAccount.private_key
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
}
