import Foundation

public struct FCMNotification: Codable {
    /// The notification's title.
    var title: String
    
    /// The notification's body text.
    var body: String
    
    /// - parameters:
    ///     - title: The notification's title.
    ///     - body: The notification's body text.
    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

public class FCMMessage: Codable {
    /// Output Only.
    /// The identifier of the message sent,
    /// in the format of projects/*/messages/{message_id}.
    public var name: String
    
    /// Input only. Arbitrary key/value payload.
    public var data: [String: String] = [:]
    
    /// Input only.
    /// Basic notification template to use across all platforms.
    public var notification: FCMNotification?
    
    /// Input only.
    /// Android specific options for messages sent through FCM connection server.
    public var android: FCMAndroidConfig?
    
    /// Input only.
    /// Webpush protocol options.
    public var webpush: FCMWebpushConfig?
    
    /// Input only.
    /// Apple Push Notification Service specific options.
    public var apns: FCMApnsConfig?
    
    //MARK: - Union field target. Required. Input only. Target to send a message to. target can be only one of the following:
    
    /// Registration token to send a message to.
    public var token: String?
    
    /// Topic name to send a message to, e.g. "weather". Note: "/topics/" prefix should not be provided.
    public var topic: String?
    
    /// Condition to send a message to, e.g. "'foo' in topics && 'bar' in topics".
    public var condition: String?
    
    /// Initialization with device token
    public init(
        token: String? = nil,
        notification: FCMNotification?,
        data: [String: String]? = nil,
        name: String? = nil,
        android: FCMAndroidConfig? = nil,
        webpush: FCMWebpushConfig? = nil,
        apns: FCMApnsConfig? = nil
    ) {
        self.token = token
        self.notification = notification
        if let data = data {
            self.data = data
        }
        self.name = name ?? UUID().uuidString
        self.android = android
        self.webpush = webpush
        self.apns = apns
    }
    
    /// Initialization with topic
    public init(
        topic: String,
        notification: FCMNotification?,
        data: [String: String]? = nil,
        name: String? = nil,
        android: FCMAndroidConfig? = nil,
        webpush: FCMWebpushConfig? = nil,
        apns: FCMApnsConfig? = nil
    ) {
        self.topic = topic
        self.notification = notification
        if let data = data {
            self.data = data
        }
        self.name = name ?? UUID().uuidString
        self.android = android
        self.webpush = webpush
        self.apns = apns
    }
    
    /// Initialization with condition
    public init(
        condition: String,
        notification: FCMNotification?,
        data: [String: String]? = nil,
        name: String? = nil,
        android: FCMAndroidConfig? = nil,
        webpush: FCMWebpushConfig? = nil,
        apns: FCMApnsConfig? = nil
    ) {
        self.condition = condition
        self.notification = notification
        if let data = data {
            self.data = data
        }
        self.name = name ?? UUID().uuidString
        self.android = android
        self.webpush = webpush
        self.apns = apns
    }
}
