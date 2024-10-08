import Foundation

final public class FCMApnsConfig: Codable {
    /// HTTP request headers defined in Apple Push Notification Service.
    /// Refer to APNs request headers for supported headers, e.g. "apns-priority": "10".
    public var headers: [String: String]
    
    /// APNs payload as a JSON object, including both aps dictionary and custom payload.
    /// See Payload Key Reference. If present, it overrides FCMNotification.title and FCMNotification.body.
    public var payload: FCMApnsPayload

    /// FCM Options to send meta data
    public var options: FCMOptions?

    //MARK: - Public Initializers
    
    init(
        headers: [String: String]? = nil,
        payload: FCMApnsPayload,
        options: FCMOptions? = nil
    ) {
        self.headers = headers ?? [:]
        self.payload = payload
        self.options = options
    }
    
    /// Use this if you need only aps object
    public convenience init(
        headers: [String: String]? = nil,
        aps: FCMApnsApsObject? = nil,
        parameters: String? = nil,
        options: FCMOptions? = nil
    ) {
        if let aps = aps {
            self.init(headers: headers, payload: FCMApnsPayload(aps: aps, parameters: parameters), options: options)
        } else {
            self.init(headers: headers, payload: FCMApnsPayload(), options: options)
        }
    }
    
    /// Returns an instance with default values
    public static var `default`: FCMApnsConfig {
        return FCMApnsConfig()
    }

    enum CodingKeys: String, CodingKey {
        case options = "fcm_options"
        case headers
        case payload
    }
}
