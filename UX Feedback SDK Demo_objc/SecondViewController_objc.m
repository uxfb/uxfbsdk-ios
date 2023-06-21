//
//  ViewController.m
//  UX Feedback SDK Demo_objc
//
//  Created by Dmitry on 03/10/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

#import "SecondViewController_objc.h"
#import <UXFeedbackSDK/UXFeedbackSDK-Swift.h>

@interface SecondViewController_objc () <UXFeedbackCampaignDelegate>


@end

@implementation SecondViewController_objc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if (UXFeedback.sharedInstance.isCampaignsLoaded == NO ){
        self.button.enabled = NO;
        [self.busyIndicator startAnimating];
    }
    
}

#pragma mark - UXFeedbackCampaignDelegate

- (void) campaignLoadedWithSuccess:(BOOL)success{
    [self.busyIndicator stopAnimating];
    self.button.enabled = YES;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) campaignErrorReceivedWithErrorString:(NSString *)errorString{
     NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) campaignDidCloseWithFeedbackResult:(FeedbackResult *)result
                isRedirectToAppStoreEnabled:(BOOL)isRedirectToAppStoreEnabled{
     NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
