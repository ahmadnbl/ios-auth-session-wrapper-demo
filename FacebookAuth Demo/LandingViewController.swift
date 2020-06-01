//
//  LandingViewController.swift
//  FacebookAuth Demo
//
//  Created by Ahmad Nabili on 01/06/20.
//  Copyright © 2020 Ahmad Nabili. All rights reserved.
//

import AuthenticationServices
import SafariServices
import UIKit


class LandingViewController: UIViewController {
    
    private var authSession: SFAuthenticationSession? = nil
//    private var webAuthSession: ASWebAuthenticationSession? = nil // need to set SDK to iOS 12 and up
    private var anAuthSession: ANAuthenticationSession?
    
    private let authURL = "https://www.facebook.com/v7.0/dialog/oauth?client_id=1810496749249486&redirect_uri=fb1810496749249486%3A%2F%2Fauthorize&scope=public_profile&response_type=token"
    private let callbackURL = "fb1810496749249486://authorize"
    
    // Example of callback reesult with given scope
    //
    // - User canceled on the Facebook's sign button:
    // fb1810496749249486://authorize/?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied#_=_
    //
    // - User logged in on the Facebook's sign flow
    // fb1810496749249486://authorize/#access_token=EAAZAuoxZBbI84BAD5ZCMUvUZBVSxYaXnIhjvaskqBD6pgyO6dryImehdAGCTSfheGTgCepCFmJZCbRDe21Y5CatHegpOB8piQZCDSdoUE9DCVRVxSCxhU1Q802e8YhzhkRD2NGtLNzWAAZBS5ZBwetQjkCdC8mQmnUP5Iro6kJHuzwZDZD&data_access_expiration_time=1598796988&expires_in=5170432
    //
    
    private let loginFbButton = UIButton(type: .system)
    private let loginFbWebAuthButton = UIButton(type: .system)
    private let loginFbANAuthButton = UIButton(type: .system)
    private let statusText = UILabel()
    
    private var genericCompletionHandler: (URL?, Error?) -> Void {
        return { [weak self] (callBack: URL?, error: Error?) in
            guard error == nil, let successURL = callBack else {
                // Log error or display error to the user here
                self?.statusText.text = "error occured"
                return
            }
            let token = successURL.getFragmentParam(key: "access_token")
            // Use your token! Send it to your backend or store it on device
            self?.statusText.text = "Got token:\n\(token)"
        }
    }
    
    private var appleNativeAuthSessionCompletionHandler: (URL?, ANAuthenticationSessionError?) -> Void {
        return { [weak self] (callBack: URL?, error: ANAuthenticationSessionError?) in
            guard error == nil, let successURL = callBack else {
                let infoMsg: String
                if let error = error {
                    infoMsg = "\(error)"
                } else {
                    infoMsg = "callback is nil? \(callBack == nil)"
                }
                // Log error or display error to the user here
                self?.statusText.text = "error occured: \(infoMsg)"
                return
            }
            let token = successURL.getFragmentParam(key: "access_token")
            // Use your token! Send it to your backend or store it on device
            self?.statusText.text = "Got token:\n\(token)"
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        loginFbButton.setTitle("Login with Facebook [SFAuth]", for: .normal)
        loginFbButton.addTarget(self, action: #selector(onFacebookAuthTap), for: .touchUpInside)
        loginFbButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginFbButton)
        NSLayoutConstraint.activate([
            loginFbButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            loginFbButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ])
        
        loginFbWebAuthButton.setTitle("Login with Facebook [WebAuth]", for: .normal)
        loginFbWebAuthButton.addTarget(self, action: #selector(onFacebookWebAuthTap), for: .touchUpInside)
        loginFbWebAuthButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginFbWebAuthButton)
        NSLayoutConstraint.activate([
            loginFbWebAuthButton.topAnchor.constraint(equalTo: loginFbButton.bottomAnchor, constant: 8),
            loginFbWebAuthButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ])
        
        loginFbANAuthButton.setTitle("Login with Facebook [ANAuth]", for: .normal)
        loginFbANAuthButton.addTarget(self, action: #selector(onFacebookANAuthTap), for: .touchUpInside)
        loginFbANAuthButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginFbANAuthButton)
        NSLayoutConstraint.activate([
            loginFbANAuthButton.topAnchor.constraint(equalTo: loginFbWebAuthButton.bottomAnchor, constant: 8),
            loginFbANAuthButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ])
        
        statusText.text = "waiting for action..."
        statusText.textColor = UIColor.lightGray
        statusText.numberOfLines = 0
        statusText.textAlignment = .center
        statusText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusText)
        NSLayoutConstraint.activate([
            statusText.topAnchor.constraint(equalTo: loginFbANAuthButton.bottomAnchor, constant: 32),
            statusText.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            statusText.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -16),
            statusText.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    @objc
    private func onFacebookAuthTap() {
        guard let url = URL(string: authURL) else { return }
        self.authSession = SFAuthenticationSession(url: url, callbackURLScheme: callbackURL, completionHandler: genericCompletionHandler)
        self.authSession?.start()
    }
    
    // need to set SDK to iOS 12 and up
    @objc
    private func onFacebookWebAuthTap() {
//        guard #available(iOS 12.0, *), let url = URL(string: authURL) else { return }
//        self.webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL, completionHandler: genericCompletionHandler)
//        if #available(iOS 13.0, *) {
//            self.webAuthSession?.presentationContextProvider = self
//            self.webAuthSession?.prefersEphemeralWebBrowserSession = true
//            self.webAuthSession?.start()
//        }
    }
    
    @objc
    private func onFacebookANAuthTap() {
        if anAuthSession == nil {
            guard let url = URL(string: authURL) else { return }
            anAuthSession = ANAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURL,
                completionHandler: appleNativeAuthSessionCompletionHandler
            )
        }
        let isStarted = anAuthSession?.start() ?? false
        print("is started: \(isStarted)")
        
    }
}

// these below need to set SDK to iOS 12 and up

//extension LandingViewController: ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return view.window ?? ASPresentationAnchor()
//    }
//}
