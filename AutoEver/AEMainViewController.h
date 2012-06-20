//
//  AEViewController.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEMainViewController : UIViewController
{
    NSURL* urlHomepage;
    UIAlertView* alertClipping;
    UIAlertView* alertClipped;
    BOOL isBlockingAutoClip;
    NSURL* urlAutoClipDidStart;
    NSURL* urlAlreadyClipped;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIWebView *webViewBack;
@property (strong, nonatomic) IBOutlet UIWebView *webViewFore;
@property (strong, nonatomic) IBOutlet UISwitch *switchIsClipping;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
@property (strong, nonatomic) IBOutlet UIView *actIndicatorBack;

- (void)webViewDidFinishLoad2:(UIWebView *)sender;
- (void)check;
- (BOOL)isContainString:(NSString*)string withUrl:(NSURL*)url;
- (IBAction)urlCheck:(id)sender;
- (void)send:(NSString*)strUrl;
- (void)messageClear;
- (void)clip;

- (void)prepareSignInWithWebView:(UIWebView*)webView;
- (void)signIn:(id)sender;

- (IBAction)goToHomepage:(id)sender;
- (IBAction)toggleSwitchIsClipping:(id)sender;

@end
