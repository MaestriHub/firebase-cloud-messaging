import Foundation
import Vapor
import Core
import NIO
import NIOHTTP1
import AsyncHTTPClient

public protocol SendAPI {
    
//    func stop(id: String, resourceId: String, queryParameters: [String: String]?) -> EventLoopFuture<EmptyResponse>
    func send(_ message: FCMMessage) async throws -> String
}

public final class FirebaseCloudMessagingSendAPI: SendAPI {
    
    let request: CloudMessagingRequest
    let encoder = JSONEncoder()
    
    init(request: CloudMessagingRequest) {
        self.request = request
    }
    
    public func send(_ message: FCMMessage) async throws -> String {
        struct Payload: Content {
            let message: FCMMessage
        }
        struct Result: GoogleCloudModel {
            let name: String
        }
        let endpoint = "https://fcm.googleapis.com/v1/projects/\(request.project)/messages:send"
        
        let payload = Payload(message: message)
        let body = try HTTPClient.Body.data(encoder.encode(payload))
        let result: Result = try await request.send(method: .POST, path: endpoint, body: body).get()
        return result.name
// OLD VERSION
//let url = actionsBaseURL + configuration.projectId + "/messages:send"
//let accessToken = try await getAccessToken()
//var headers = HTTPHeaders()
//headers.bearerAuthorization = .init(token: accessToken)
//let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
//    struct Payload: Content {
//        let message: FCMMessageDefault
//    }
//    let payload = Payload(message: message)
//    try req.content.encode(payload)
//}
//try await clientResponse.validate()
//struct Result: Decodable {
//    let name: String
//}
//let result = try clientResponse.content.decode(Result.self)
//return result.name
    }
}
