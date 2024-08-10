import Vapor

public enum FirebaseCloudMessagingError: GoogleCloudError {
    case projectIdMissing
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .projectIdMissing:
            return "Missing project id for FirebaseCloudMessaging API. Did you forget to set your project id?"
        case .unknownError(let reason):
            return "An unknown error occured: \(reason)"
        }
    }
}

public struct CloudMessagingAPIError: GoogleCloudError, GoogleCloudModel {
    /// A container for the error information.
    public var error: CloudMessagingAPIErrorBody
}

public struct CloudMessagingAPIErrorBody: Codable {
    /// A container for the error details.
    public var errors: [CloudMessagingError]
    /// An HTTP status code value, without the textual description.
    public var code: Int
    /// Description of the error. Same as `errors.message`.
    public var message: String
}

public struct CloudMessagingError: Codable {
    /// The scope of the error. Example values include: global, push and usageLimits.
    public var domain: String?
    /// Example values include invalid, invalidParameter, and required.
    public var reason: String?
    /// Description of the error.
    /// Example values include Invalid argument, Login required, and Required parameter: project.
    public var message: String?
    /// The location or part of the request that caused the error. Use with location to pinpoint the error. For example, if you specify an invalid value for a parameter, the locationType will be parameter and the location will be the name of the parameter.
    public var locationType: String?
    /// The specific item within the locationType that caused the error. For example, if you specify an invalid value for a parameter, the location will be the name of the parameter.
    public var location: String?
}

public struct GoogleError: Error, Decodable {
    public let code: Int
    public let message: String
    public let status: String
    public let fcmError: FCMError?

    private enum TopLevelCodingKeys: String, CodingKey {
        case error
    }

    private enum CodingKeys: String, CodingKey {
        case code, message, status, details
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TopLevelCodingKeys.self)
            .nestedContainer(keyedBy: CodingKeys.self, forKey: .error)

        code = try container.decode(Int.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        status = try container.decode(String.self, forKey: .status)

        var details = try container.nestedUnkeyedContainer(forKey: .details)
        fcmError = try? details.decode(FCMError.self)
    }
}

public struct FCMError: Error, Decodable {
    public let errorCode: ErrorCode

    public enum ErrorCode: String, Decodable {
        case unspecified = "UNSPECIFIED_ERROR"
        case invalid = "INVALID_ARGUMENT"
        case unregistered = "UNREGISTERED"
        case senderIDMismatch = "SENDER_ID_MISMATCH"
        case quotaExceeded = "QUOTA_EXCEEDED"
        case apnsAuth = "APNS_AUTH_ERROR"
        case unavailable = "UNAVAILABLE"
        case `internal` = "INTERNAL"
    }
}

