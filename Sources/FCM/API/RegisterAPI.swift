//
//  FirebaseCloudRegisterAPI.swift
//  Created by Vitalii Shevtsov on 8/10/24.
//

import Foundation
import Vapor
import Core
import NIO
import NIOHTTP1
import AsyncHTTPClient

public struct APNSToFirebaseToken {
    public let registration_token, apns_token: String
    public let isRegistered: Bool
}

public protocol RegisterAPI {
    
//    func stop(id: String, resourceId: String, queryParameters: [String: String]?) -> EventLoopFuture<EmptyResponse>
    func registerAPNS(
        appBundleId: String,
        sandbox: Bool,
        tokens: [String]
    ) async throws -> [APNSToFirebaseToken]
}

public final class FirebaseCloudMessagingRegisterAPI: RegisterAPI {
    
    let request: CloudMessagingRequest
    let encoder = JSONEncoder()
    
    init(request: CloudMessagingRequest) {
        self.request = request
    }
    
    public func registerAPNS(
        appBundleId: String,
        sandbox: Bool = false,
        tokens: [String]
    ) async throws -> [APNSToFirebaseToken] {
        guard tokens.count <= 100 else {
            throw Abort(.internalServerError, reason: "FCM: Register APNS: tokens count should be less or equeal 100")
        }
        guard tokens.count > 0 else {
            return []
        }
        
        struct Payload: Content {
            let application: String
            let sandbox: Bool
            let apns_tokens: [String]
        }
        struct Result: GoogleCloudModel {
            struct Result: Codable {
                let registration_token, apns_token, status: String
            }
            let results: [Result]
        }
        let endpoint = "https://iid.googleapis.com/iid/v1:batchImport"
        
        let payload = Payload(application: appBundleId, sandbox: sandbox, apns_tokens: tokens)
        
        let body = try HTTPClient.Body.data(encoder.encode(payload))
        let result: Result = try await request.send(method: .POST, path: endpoint, body: body).get()
        return result.results.map {
            .init(registration_token: $0.registration_token, apns_token: $0.apns_token, isRegistered: $0.status == "OK")
        }
// OLD VERSION
//let url = "https://iid.googleapis.com/iid/v1:batchImport"
//var headers = HTTPHeaders()
//headers.add(name: .authorization, value: "key=\(serverKey)")
//
//let clientResponse = try await client.post(URI(string: url), headers: headers) { req in
//    struct Payload: Content {
//        let application: String
//        let sandbox: Bool
//        let apns_tokens: [String]
//    }
//    let payload = Payload(application: appBundleId, sandbox: sandbox, apns_tokens: tokens)
//    try req.content.encode(payload)
//}
//try await clientResponse.validate()
//struct Result: Codable {
//    struct Result: Codable {
//        let registration_token, apns_token, status: String
//    }
//    let results: [Result]
//}
//let result = try clientResponse.content.decode(Result.self)
//return result.results.map {
//    .init(registration_token: $0.registration_token, apns_token: $0.apns_token, isRegistered: $0.status == "OK")
//}
    }
}
