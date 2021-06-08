//
//  AppDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UXFeedbackSDK

let uxfAppID = "ckh8zduea00003c58k6cyatp0"

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
        
        DDLogDebug("Start application")
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
        
//        customTheme.fontBoldName = "SnellRoundhand-Black"
//        customTheme.fontMediumName = "SnellRoundhand-Bold"
//        customTheme.fontRegularName = "SnellRoundhand"
        
        UXFeedback.sharedSDK.resetAllCampaignsData {
            
        }
        
        UXFeedback.sharedSDK.setup(appID: uxfAppID)
        
//        UXFeedback.sharedSDK.setup(appID: uxfAppID, theme: customTheme) { (success) in
//
//        }
        
        /*for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }*/
        
        //print(String(describing: UIDevice.current.identifierForVendor?.uuidString))
//        let theme: UXFBTheme = UXFBTheme.init()
//        customTheme.backgroundColor = UIColor.groupTableViewBackground
//        customTheme.titleColor = UIColor.brown
//        customTheme.textColor = UIColor.black
//        customTheme.errorColor = UIColor.red
//        customTheme.controlColor = UIColor.blue
//        customTheme.inputBackgroundColor = UIColor.lightGray
//        customTheme.inputTextColor = UIColor.darkGray
//        customTheme.formRadius = 20.0
//        theme.fontBoldName = "SnellRoundhand-Black"
//        theme.fontMediumName = "SnellRoundhand-Bold"
//        theme.fontRegularName = "SnellRoundhand"
        
//        for family in UIFont.familyNames {
//                print("family:", family)
//                for font in UIFont.fontNames(forFamilyName: family) {
//                    print("font:", font)
//                }
//            }
//
//        UXFeedback.sharedSDK.setup(appID: uxfAppID, theme: theme) { (success) in
//            let message = "UXFeedback initialization " + (success == true ? "successful" : "failed")
//            DDLogDebug(message)
//        }
//
//        UXFeedback.sharedInstance.setup(appID: uxfAppID)//, theme: customTheme)
//        {  success in
//            let message = "UXFeedback initialization " + (success == true ? "successful" : "failed")
//            DDLogDebug(message)
//        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

