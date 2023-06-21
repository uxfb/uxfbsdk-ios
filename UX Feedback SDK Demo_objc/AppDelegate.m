//
//  AppDelegate.m
//  UX Feedback SDK Demo_objc
//
//  Created by Dmitry on 03/10/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

#import "AppDelegate.h"
#import <UXFeedbackSDK/UXFeedbackSDK-Swift.h>

void DDLogDebug(id object){
    NSLog(@"%@", object);
}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSLog(@"Start ObjC application");
    
    Theme *theme = [[Theme alloc] init];
    
    NSString *uxfAppID = @"54444d444a068c157e7f7e14";
    if (UXFeedback.isStage == YES){
        uxfAppID = @"cjld2cjxh0000qzrmn831i7rn";
    }
    
    [UXFeedback.sharedSDK setupWithAppID: uxfAppID
                                        theme: theme
                                   completion:^(BOOL success) {
        NSString *message = [NSString stringWithFormat: @"UXFeedback objc initialization %@", (success == true ? @"successful" : @"failed")];
        DDLogDebug(message);
    }];
    
    return YES;
}
@end
