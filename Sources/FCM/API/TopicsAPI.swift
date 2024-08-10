import Foundation
import Vapor

//extension FCM {
//    public func getTopics(token: String) async throws -> [String] {
//        guard let configuration = self.configuration else {
//            fatalError("FCM not configured. Use app.fcm.configuration = ...")
//        }
//        guard let serverKey = configuration.serverKey else {
//            fatalError("FCM: GetTopics: Server Key is missing.")
//        }
//        let url = "https://iid.googleapis.com/iid/v1:info/\(token)?details=true"
//        var headers = HTTPHeaders()
//        headers.add(name: .authorization, value: "key=\(serverKey)")
//        let clientResponse = try await client.get(URI(string: url), headers: headers)
//        try await clientResponse.validate()
//        struct Result: Codable {
//            let rel: Relations
//            
//            struct Relations: Codable {
//                let topics: [String: TopicMetadata]
//            }
//            
//            struct TopicMetadata: Codable {
//                let addDate: String
//            }
//        }
//        let result = try clientResponse.content.decode(Result.self, using: JSONDecoder())
//        return Array(result.rel.topics.keys)
//    }
//}
//
//extension FCM {
//    public func deleteTopic(_ name: String, tokens: String...) async throws {
//        try await deleteTopic(name, tokens: tokens)
//    }
//    
//    public func deleteTopic(_ name: String, tokens: [String]) async throws {
//        guard let configuration = self.configuration else {
//            fatalError("FCM not configured. Use app.fcm.configuration = ...")
//        }
//        guard let serverKey = configuration.serverKey else {
//            fatalError("FCM: DeleteTopic: Server Key is missing.")
//        }
//        let url = "https://iid.googleapis.com/iid/v1:batchRemove"
//        var headers = HTTPHeaders()
//        headers.add(name: .authorization, value: "key=\(serverKey)")
//        let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
//            struct Payload: Content {
//                let to: String
//                let registration_tokens: [String]
//                
//                init(to: String, registration_tokens: [String]) {
//                    self.to = "/topics/\(to)"
//                    self.registration_tokens = registration_tokens
//                }
//            }
//            let payload = Payload(to: name, registration_tokens: tokens)
//            try req.content.encode(payload)
//        }
//        try await clientResponse.validate()
//    }
//}
//
//extension FCM {
//    public func createTopic(_ name: String? = nil, tokens: String...) async throws -> String {
//        try await createTopic(name, tokens: tokens)
//    }
//    
//    public func createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
//        guard let configuration = self.configuration else {
//            fatalError("FCM not configured. Use app.fcm.configuration = ...")
//        }
//        guard let serverKey = configuration.serverKey else {
//            fatalError("FCM: CreateTopics: Server Key is missing.")
//        }
//        let url = "https://iid.googleapis.com/iid/v1:batchAdd"
//        let name = name ?? UUID().uuidString
//        var headers = HTTPHeaders()
//        headers.add(name: .authorization, value: "key=\(serverKey)")
//        let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
//            struct Payload: Content {
//                let to: String
//                let registration_tokens: [String]
//                
//                init(to: String, registration_tokens: [String]) {
//                    self.to = "/topics/\(to)"
//                    self.registration_tokens = registration_tokens
//                }
//            }
//            let payload = Payload(to: name, registration_tokens: tokens)
//            try req.content.encode(payload)
//        }
//        try await clientResponse.validate()
//        return name
//    }
//}
