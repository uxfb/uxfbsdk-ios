//
//  MainViewController.m
//  UX Feedback SDK Demo_objc
//
//  Created by Dmitry on 04/10/2019.
//  Copyright © 2019 UXF. All rights reserved.
//

#import "MainViewController_objc.h"
#import <UXFeedbackSDK/UXFeedbackSDK-Swift.h>

@interface MainViewController_objc () <UXFeedbackCampaignDelegate, UXFeedbackFormDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *busyIndicator;
@property (nonatomic, weak) IBOutlet UIButton *dismissButton;
@property (nonatomic, weak) IBOutlet UIView *buttonsStackView;

@end

@implementation MainViewController_objc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UXFeedback.sharedInstance.delegate = self;
    UXFeedback.sharedInstance.formDelegate = self;
           
           if (UXFeedback.sharedInstance.isCampaignsLoaded == NO) {
               self.buttonsStackView.userInteractionEnabled = NO;
               self.buttonsStackView.alpha = 0.5f;
               [self.busyIndicator startAnimating];
           }
           
    self.dismissButton.hidden = (self.navigationController != nil);
}

- (IBAction) eventTap: (UIButton*) sender{

    NSInteger eventNumber = sender.tag;
    NSAssert(eventNumber > 0, @"Invalid eventNumber");
 
    NSString *eventName = [NSString stringWithFormat: @"event%ld", (long)eventNumber];
    [UXFeedback.sharedInstance sendEventWithEvent: eventName fromController: self];
}

- (IBAction) closeButtonTap: (UIButton*) sender{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - UXFeedbackCampaignDelegate
- (void) campaignLoadedWithSuccess:(BOOL)success{
    [self.busyIndicator stopAnimating];
    self.buttonsStackView.userInteractionEnabled = YES;
    self.buttonsStackView.alpha = 1.0f;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) campaignErrorReceivedWithErrorString:(NSString *)errorString{
     NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) campaignDidCloseWithFeedbackResult:(FeedbackResult *)result
                isRedirectToAppStoreEnabled:(BOOL)isRedirectToAppStoreEnabled{
     NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UXFeedbackFormDelegate

- (void) formDidLoadedWithForm:(UXFViewController *)form{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self presentViewController: form animated: YES completion: nil];
}

- (void) formDidFailLoadingWithError:(UXFError *)error{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) formDidCloseWithFormID:(NSString *)formID
            withFeedbackResults:(NSArray<FeedbackResult *> *)results
    isRedirectToAppStoreEnabled:(BOOL)isRedirectToAppStoreEnabled{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) formWillCloseWithForm:(UXFViewController *)form
                        formID:(NSString *)formID
           withFeedbackResults:(NSArray<FeedbackResult *> *)results
   isRedirectToAppStoreEnabled:(BOOL)isRedirectToAppStoreEnabled{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
