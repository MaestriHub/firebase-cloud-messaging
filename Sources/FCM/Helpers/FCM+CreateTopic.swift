import Foundation
import Vapor

extension FCM {
     public func createTopic(_ name: String? = nil, tokens: String...) async throws -> String {
         try await createTopic(name, tokens: tokens)
     }

     public func createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
         try await _createTopic(name, tokens: tokens)
     }

     private func _createTopic(_ name: String? = nil, tokens: [String]) async throws -> String {
         guard let configuration = self.configuration else {
             fatalError("FCM not configured. Use app.fcm.configuration = ...")
         }
         let url = self.iidURL + "batchAdd"
         let name = name ?? UUID().uuidString
         var headers = HTTPHeaders()
         headers.add(name: .authorization, value: "key=\(serverKey)")
         let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
             struct Payload: Content {
                 let to: String
                 let registration_tokens: [String]

                 init(to: String, registration_tokens: [String]) {
                     self.to = "/topics/\(to)"
                     self.registration_tokens = registration_tokens
                 }
             }
             let payload = Payload(to: name, registration_tokens: tokens)
             try req.content.encode(payload)
         }
         try await clientResponse.validate()
         return name
     }
 }
