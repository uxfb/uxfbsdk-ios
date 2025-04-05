//
//  AppDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
//import YoHeSDK
import UXFeedbackSDK

//let uxfAppID = "ckzxywct400003965yjfzyp5m" //dev
//let uxfAppID = "clxumovt700003d5t606qrz5p"
//let uxfAppID = "cl0dv9ld600033963rtwqowiu" //prod
let uxfAppID = "ck9n0jwi000003b5x7566k1n2" //gosuslugi
//let uxfAppID = "ck78uf73w0000315rlomponmb" //crashes

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
        
        let customTheme = UXFBTheme()
        customTheme.text03Color =  UIColor.init("#8B90A0")
        customTheme.inputBorderColor =  UIColor.init("#D3D4D8")
        customTheme.iconColor = .blue //UIColor.init("#B5B8C2")
        customTheme.btnBgColorActive =  UIColor.init("#1983C8")
        customTheme.btnBorderRadius = 4
        customTheme.errorColorSecondary =  UIColor.init("#F4A0A3")
        customTheme.errorColorPrimary = .cyan// UIColor.init("#E84047")
        customTheme.mainColor = .green// UIColor.init("#0076C2")
        customTheme.controlBgColorActive = .lightGray// UIColor.init("#DBF1FF")
        customTheme.formBorderRadius = 8
        customTheme.inputBgColor =  UIColor.init("#F3F3F3")
        customTheme.text01Color = .green// UIColor.init("#232735")
        customTheme.controlBgColor = .red// UIColor.init("#ABCABC")
        customTheme.controlIconColor =  .yellow//UIColor.init("#FFFFFF")
        customTheme.btnBgColor = .orange// UIColor.init("#0076C2")
        customTheme.text02Color =  UIColor.init("#505565")
        customTheme.btnTextColor = .magenta// UIColor.init("#FFFFFF")
        customTheme.bgColor =  UIColor.init("#000000")
//        customTheme.fontP1 = .boldSystemFont(ofSize: 14)
        
//    endpoint: "AAAAAAAAAAAAAHYwMhEVF1hOTAolMWgBABIHDQwbey0+AwABBgMCCD52NBA=",
      let settings = UXFBSettings()
      settings.debugEnabled = true
    settings.slideInUiBlocked = false
        
        UXFeedback.setup(appID: uxfAppID,
                         settings: settings)
        
//        UXFeedback.sdk.theme = customTheme
        UXFeedback.sdk.settings.debugEnabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
}

