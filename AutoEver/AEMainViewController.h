//
//  AEViewController.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEWebViewBack.h"

@class AEWebViewBack;

@interface AEMainViewController : UIViewController
{
    NSURL* urlHomepage;
    UIAlertView* alertClipping;
    UIAlertView* alertClipped;
    NSURL* urlAutoClipDidStart;
    NSURL* urlAlreadyClipped;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet AEWebViewBack *webViewBack;
@property (strong, nonatomic) IBOutlet UIWebView *webViewFore;
@property (strong, nonatomic) IBOutlet UISwitch *switchIsClipping;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
@property (strong, nonatomic) IBOutlet UIView *actIndicatorBack;
@property BOOL blockingAutoClip;
@property NSURL* urlAlreadyClipped;

- (void)webViewDidFinishLoad2:(UIWebView *)sender;
- (void)check;
- (BOOL)URLContainString:(NSString*)string withUrl:(NSURL*)url;
- (IBAction)urlCheck:(id)sender;

//- (void)prepareSignInWithWebView:(UIWebView*)webView;
//- (void)signIn:(id)sender;

- (IBAction)goToHomepage:(id)sender;
- (IBAction)toggleSwitchIsClipping:(id)sender;

@end
