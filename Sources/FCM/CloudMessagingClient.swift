import Vapor
import Foundation
import Core
import AsyncHTTPClient
import NIO

public final class CloudMessagingClient {
    
    public var register: RegisterAPI
    public var send: SendAPI
    var cloudMessagingRequest: CloudMessagingRequest
    
    public init(
        credentials: GoogleCloudCredentialsConfiguration,
        config: CloudMessagingConfiguration,
        httpClient: HTTPClient,
        eventLoop: EventLoop
    ) throws {
        let refreshableToken = OAuthCredentialLoader.getRefreshableToken(
            credentials: credentials,
            withConfig: config,
            andClient: httpClient,
            eventLoop: eventLoop
        )
        
        /// Set the projectId to use for this client. In order of priority:
        /// - Environment Variable (PROJECT_ID)
        /// - Service Account's projectID
        /// - `CloudMessagingConfiguration` `project` property (optionally configured).
        /// - `GoogleCloudCredentialsConfiguration's` `project` property (optionally configured).
        
        guard let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ??
                (refreshableToken as? OAuthServiceAccount)?.credentials.projectId ??
                config.project ?? credentials.project else {
            throw CloudMessagingError.projectIdMissing
        }
        
        cloudMessagingRequest = CloudMessagingRequest(
            httpClient: httpClient,
            eventLoop: eventLoop,
            oauth: refreshableToken,
            project: projectId
        )
        
        register = FirebaseCloudMessagingRegisterAPI(request: cloudMessagingRequest)
        send = FirebaseCloudMessagingSendAPI(request: cloudMessagingRequest)
    }
    
    /// Hop to a new eventloop to execute requests on.
    /// - Parameter eventLoop: The eventloop to execute requests on.
    public func hopped(to eventLoop: EventLoop) -> CloudMessagingClient {
        cloudMessagingRequest.eventLoop = eventLoop
        return self
    }
}
