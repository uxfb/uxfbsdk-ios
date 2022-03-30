//
//  AppDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UXFeedbackSDK

//let uxfAppID = "ckh8zduea00003c58k6cyatp0"
//let uxfAppID = "ckx7i7p7k00003c5l7dv6ue7t"

let uxfAppID = "cl0z3qass000038651z5z7jbe"

internal func DDLogDebug(_ value: Any){
    #if DEBUG
        print(value)
    #endif
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UXFeedback.sharedSDK.setDebugEnabled(true)
        
        let customTheme = UXFBTheme()
        customTheme.text03Color =  UIColor.init("#8B90A0")
        customTheme.inputBorderColor =  UIColor.init("#D3D4D8")
        customTheme.iconColor =  UIColor.init("#B5B8C2")
        customTheme.btnBgColorActive =  UIColor.init("#1983C8")
        customTheme.btnBorderRadius = 4
        customTheme.errorColorSecondary =  UIColor.init("#F4A0A3")
        customTheme.errorColorPrimary =  UIColor.init("#E84047")
        customTheme.mainColor =  UIColor.init("#0076C2")
        customTheme.controlBgColorActive =  UIColor.init("#DBF1FF")
        customTheme.formBorderRadius = 8
        customTheme.inputBgColor =  UIColor.init("#F3F3F3")
        customTheme.text01Color =  UIColor.init("#232735")
        customTheme.controlBgColor =  UIColor.init("#F3F3F3")
        customTheme.controlIconColor =  UIColor.init("#FFFFFF")
        customTheme.btnBgColor =  UIColor.init("#0076C2")
        customTheme.text02Color =  UIColor.init("#505565")
        customTheme.btnTextColor =  UIColor.init("#FFFFFF")
        customTheme.bgColor =  UIColor.init("#000000")
        
        UXFeedback.sharedSDK.resetAllCampaignsData { }
        
//    endpoint: "AAAAAAAAAAAAAHYwMhEVF1hOTAolMWgBABIHDQwbey0+AwABBgMCCD52NBA=", 
        UXFeedback.sharedSDK.setup(appID: uxfAppID, window: window, theme: nil) { success in
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

