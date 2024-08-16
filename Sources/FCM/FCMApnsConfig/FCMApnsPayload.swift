/// Default APNS payload model
/// it contains aps dictionary inside
/// you can use your own custom payload class
/// it just should conform to FCMApnsPayloadProtocol
///

public struct FCMApnsPayload: Codable, Equatable {

    /// The APS object, primary alert
    public var aps: FCMApnsApsObject
    public var parameters: String?

    public init(
        aps: FCMApnsApsObject? = nil,
        parameters: String? = nil
    ) {
        self.aps = aps ?? FCMApnsApsObject.default
        self.parameters = parameters
    }
}
