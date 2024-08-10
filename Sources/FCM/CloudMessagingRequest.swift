//
//  CloudMessagingRequest.swift
//  Created by Vitalii Shevtsov on 8/10/24.
//

import Core
import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

class CloudMessagingRequest: GoogleCloudAPIRequest {
    
    let refreshableToken: OAuthRefreshable
    let project: String
    let httpClient: HTTPClient
    let responseDecoder: JSONDecoder = JSONDecoder()
    var currentToken: OAuthAccessToken?
    var tokenCreatedTime: Date?
    var eventLoop: EventLoop
    
    init(httpClient: HTTPClient, eventLoop: EventLoop, oauth: OAuthRefreshable, project: String) {
        self.refreshableToken = oauth
        self.httpClient = httpClient
        self.project = project
        self.eventLoop = eventLoop
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.responseDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func send<GCM: GoogleCloudModel>(
        method: HTTPMethod,
        headers: HTTPHeaders = [:],
        path: String,
        query: String = "",
        body: HTTPClient.Body = .data(Data())
    ) -> EventLoopFuture<GCM> {
        return withToken { token in
            return self._send(method: method, headers: headers, path: path, query: query, body: body, accessToken: token.accessToken).flatMap { response in
                do {
                    let model = try self.responseDecoder.decode(GCM.self, from: response)
                    return self.eventLoop.makeSucceededFuture(model)
                } catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
            }
        }
    }

    private func _send(
        method: HTTPMethod,
        headers: HTTPHeaders,
        path: String,
        query: String,
        body: HTTPClient.Body,
        accessToken: String
    ) -> EventLoopFuture<Data> {
        var _headers = headers
        _headers.bearerAuthorization = .init(token: accessToken)
        _headers.contentType = .json
        
//        let clientResponse = try await client.post(URI(string: url), headers: headers) { (req) in
//            struct Payload: Content {
//                let message: FCMMessageDefault
//            }
//            let payload = Payload(message: message)
//            try req.content.encode(payload)
//        }
        do {
            let request = try HTTPClient.Request(url: "\(path)?\(query)", method: method, headers: _headers, body: body)
            
            return httpClient.execute(request: request, eventLoop: .delegate(on: self.eventLoop)).flatMap { response in
                // If we get a 204 for example in the delete api call just return an empty body to decode.
                // https://cloud.google.com/s/results/?q=If+successful%2C+this+method+returns+an+empty+response+body.&p=%2Fstorage%2Fdocs%2F
                if response.status == .noContent {
                    return self.eventLoop.makeSucceededFuture("{}".data(using: .utf8)!)
                }

                guard var byteBuffer = response.body else {
                    fatalError("Response body from Google is missing! This should never happen.")
                }
                let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!

                guard (200..<300).contains(response.status.code) else {
                    let error: Error
                    if let jsonError = try? self.responseDecoder.decode(CloudMessagingAPIError.self, from: responseData) {
                        error = jsonError
                    } else {
                        let body = response.body?.getString(at: response.body?.readerIndex ?? 0, length: response.body?.readableBytes ?? 0) ?? ""
                        error = CloudMessagingAPIError(error: CloudMessagingAPIErrorBody(errors: [], code: Int(response.status.code), message: body))
                    }

                    return self.eventLoop.makeFailedFuture(error)
                }
                return self.eventLoop.makeSucceededFuture(responseData)
            }
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
}

//extension ClientResponse {
//    func validate() async throws {
//        guard 200 ..< 300 ~= status.code else {
//            if let error = try? content.decode(GoogleError.self) {
//                throw error
//            }
//
//            let body = body.map(String.init) ?? ""
//            throw Abort(.internalServerError, reason: "FCM: Unexpected error '\(body)'")
//        }
//    }
//}
