//
//  ANAuthenticationSession.swift
//  FacebookAuth Demo
//
//  Created by Ahmad Nabili on 01/06/20.
//  Copyright © 2020 Ahmad Nabili. All rights reserved.
//

import AuthenticationServices
import Foundation
import SafariServices

/// Enum that represent error when doing authentication.
internal enum ANAuthenticationSessionError {
    // user tapped cancel on either confirmation dialog or authentication page
    case canceled
    // these two related to ASWebAuthenticationSession's technical problem. You can google it for these two cases
    case presentationContextNotProvided
    case presentationContextInvalid
    // got unexpected error
    case unknown(error: Error)
    
    internal static func interpretFrom(error: Error?) -> ANAuthenticationSessionError? {
        guard let error = error else { return nil }
        
        let nsError = error as NSError
        
        guard nsError.domain == "com.apple.AuthenticationServices.WebAuthenticationSession"
            || nsError.domain == "com.apple.SafariServices.Authentication" else {
                return ANAuthenticationSessionError.unknown(error: error)
        }
        
        if nsError.code == SFAuthenticationError.canceledLogin.rawValue {
            return ANAuthenticationSessionError.canceled
            
        } else if #available(iOS 12.0, *),
            nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            return ANAuthenticationSessionError.canceled
            
        } else if #available(iOS 13.0, *),
            nsError.code == ASWebAuthenticationSessionError.presentationContextNotProvided.rawValue {
            return ANAuthenticationSessionError.presentationContextNotProvided
            
        } else if #available(iOS 13.0, *),
            nsError.code == ASWebAuthenticationSessionError.presentationContextInvalid.rawValue {
            return ANAuthenticationSessionError.presentationContextInvalid
            
        } else {
            return ANAuthenticationSessionError.unknown(error: error)
        }
    }
}

/// The wrapper that utilize Apple's Authentication Session manager,
/// both SFAuthenticationSession and ASWebAuthenticationSession.
internal class ANAuthenticationSession: NSObject {
    
    private var currentAuthenticationSession: ANAuthenticationSessionProtocol?
    private var isRunning: Bool = false
    
    private let url: URL
    private let callbackURLScheme: String?
    private let prefersEphemeralWebBrowserSession: Bool
    private let presentationContextWindow: UIWindow?
    private let completionHandler: (URL?, ANAuthenticationSessionError?) -> Void
    
    private var genericCompletionHandler: (URL?, Error?) -> Void {
        return { [weak self] (callBack: URL?, error: Error?) in
            guard let self = self else { return }
            self.isRunning = false
            self.completionHandler(callBack, ANAuthenticationSessionError.interpretFrom(error: error))
        }
    }
    
    /** @abstract Returns an ANAuthenticationSession object.
    @param URL the initial URL pointing to the authentication webpage. Only supports URLs with http:// or https:// schemes.
    @param callbackURLScheme the custom URL scheme that the app expects in the callback URL. To use this, YOU MUST specify this given value on URL Schemes Type settings in the project's Info section.
    @param prefersEphemeralWebBrowserSession only has effect on iOS 13 and up. Indicates whether this session should ask the browser for an ephemeral session.
     Ephemeral web browser sessions do not not share cookies or other browsing data with a user's normal browser session.
     This value is NO by default.
    @param presentationContextWindow only has effect on iOS 13 and up. Define in which window this Authentication Sesswion will be shown. This will support Apple's multi-window app flow.
    @param completionHandler the completion handler which is called when the session is completed successfully or canceled by user.
            - URL defines of retrieved URL when callbackURL was met
            - Error defines the error occured when doing authentication session.
    */
    internal init(url URL: URL,
         callbackURLScheme: String?,
         prefersEphemeralWebBrowserSession: Bool = false,
         presentationContextWindow: UIWindow? = nil,
         completionHandler: @escaping (URL?, ANAuthenticationSessionError?) -> Void) {
        
        self.url = URL
        self.callbackURLScheme = callbackURLScheme
        self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        self.presentationContextWindow = presentationContextWindow
        self.completionHandler = completionHandler
    }

    /** @abstract Starts the Authentication Session instance after it is instantiated.
    @result Returns YES if the session starts successfully.
    */
    internal func start() -> Bool {
        if #available(iOS 12, *) {
            return attemptStartASWebAuthenticationSession()
        } else {
            return attemptStartSFAuthenticationSession()
        }
    }
    
    /** @abstract Cancel an Authentication Session. If the view controller is already presented to load the webpage for
    authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
    */
    internal func cancel() {
        currentAuthenticationSession?.cancel()
    }
    
    private func attemptStartSFAuthenticationSession() -> Bool {
        guard !isRunning else { return false }
        let newSession  = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: genericCompletionHandler)
        currentAuthenticationSession = newSession
        isRunning = currentAuthenticationSession!.start()
        return isRunning
    }
    
    @available(iOS 12.0, *)
    private func attemptStartASWebAuthenticationSession() -> Bool {
        guard !isRunning else { return false }
        let newSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: genericCompletionHandler)
        if #available(iOS 13.0, *) {
            newSession.presentationContextProvider = self
        }
        currentAuthenticationSession = newSession
        isRunning = currentAuthenticationSession!.start()
        return isRunning
    }
}

/// Extension to conform to the ASWebAuthentication neede for providing presentation context, which define in which window the Authentication Service will be shown.
@available(iOS 12.0, *)
extension ANAuthenticationSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return presentationContextWindow ?? ASPresentationAnchor()
    }
}
