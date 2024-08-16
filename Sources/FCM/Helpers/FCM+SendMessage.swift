import Foundation
import Vapor

extension FCM {
     public func send(_ message: FCMMessage) async throws -> String {
         guard let configuration = self.configuration else {
             fatalError("FCM not configured. Use app.fcm.configuration = ...")
         }

         let url = "https://fcm.googleapis.com/v1/projects/" + configuration.projectId + "/messages:send"
         let accessToken = try await getAccessToken()
         var headers = HTTPHeaders()
         headers.bearerAuthorization = .init(token: accessToken)
         let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
             struct Payload: Content {
                 let message: FCMMessage
             }
             let payload = Payload(message: message)
             try req.content.encode(payload)
         }
         try await clientResponse.validate()
         struct Result: Decodable {
             let name: String
         }
         let result = try clientResponse.content.decode(Result.self)
         return result.name
     }
 }
