//
//  ANAuthenticationSessionProtocol.swift
//  FacebookAuth Demo
//
//  Created by Ahmad Nabili on 01/06/20.
//  Copyright © 2020 Ahmad Nabili. All rights reserved.
//
// Kudos to:
// https://medium.com/@adrianmsliwa/wrapper-design-pattern-by-example-using-sfauthenticationsession-and-aswebauthenticationsession-fe5f4e83c386
//

import AuthenticationServices
import Foundation
import SafariServices

/// The protocol that defines the Apple's native authentication session manager generic behavior,
/// both SFAuthenticationSession and ASWebAuthenticationSession.
/// In order to use this benefir, you can use -[ANAuthenticationSession] instead.
internal protocol ANAuthenticationSessionProtocol {
    
    /** @abstract Returns an Authentication Session Manager object that conform to ANAuthenticationSessionProtocol.
    @param URL the initial URL pointing to the authentication webpage. Only supports URLs with http:// or https:// schemes.
    @param callbackURLScheme the custom URL scheme that the app expects in the callback URL.
    @param completionHandler the completion handler which is called when the session is completed successfully or canceled by user.
            - URL defines of retrieved URL when callbackURL was met
            - Error defines the error occured when doing authentication session.
    */
    init(url URL: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping (URL?, Error?) -> Void)

    /** @abstract Starts the Authentication Session instance after it is instantiated.
    @discussion start can only be called once for an ASWebAuthenticationSession instance. This also means calling start on a
     canceled session will fail.
    @result Returns YES if the session starts successfully.
    */
    func start() -> Bool
    
    /** @abstract Cancel an Authentication Session. If the view controller is already presented to load the webpage for
    authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
    */
    func cancel()
}

extension SFAuthenticationSession: ANAuthenticationSessionProtocol {}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: ANAuthenticationSessionProtocol {}
