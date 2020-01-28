//
//  AppDelegate.swift
//  UX Feedback Demo
//
//  Created by Dmitry Kudryavtsev on 11.03.2019.
//  Copyright © 2019 UXF. All rights reserved.
//

import UIKit
import UXFeedbackSDK

let uxfAppID = UXFeedback.isStage == true ? "cjld2cjxh0000qzrmn831i7rn" : "54444d444a068c157e7f7e14"
//let uxfAppID = "ck5peux4c00003h5mcloo8opu"

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
        
        
        /*for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }*/
        
        //print(String(describing: UIDevice.current.identifierForVendor?.uuidString))
        let customTheme: UXFTheme = UXFTheme.init()
        customTheme.backgroundColor = UIColor.groupTableViewBackground
        customTheme.titleColor = UIColor.brown
        customTheme.textColor = UIColor.black
        customTheme.errorColor = UIColor.red
        customTheme.controlColor = UIColor.blue
        customTheme.inputBackgroundColor = UIColor.lightGray
        customTheme.inputTextColor = UIColor.darkGray
        customTheme.formRadius = 20.0
        
       // customTheme.fontRegularName = "Marker Felt"
       // customTheme.fontBoldName = "YourBoldFontName"
        customTheme.fontMediumName = "Marker Felt"
        
        UXFeedback.sharedInstance.setup(appID: uxfAppID)//, window: self.window!)
        {  success in
            let message = "UXFeedback initialization " + (success == true ? "successful" : "failed")
            DDLogDebug(message)
        }

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

