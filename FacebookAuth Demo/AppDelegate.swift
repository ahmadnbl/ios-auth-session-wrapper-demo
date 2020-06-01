//
//  AppDelegate.swift
//  FacebookAuth Demo
//
//  Created by Ahmad Nabili on 01/06/20.
//  Copyright © 2020 Ahmad Nabili. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LandingViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

}

