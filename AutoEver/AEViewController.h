//
//  AEViewController.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEViewController : UIViewController
{
    NSURL* urlHomepage;
    UIAlertView* alertClipping;
    UIAlertView* alertClipped;
    Boolean isClipping;
    NSURL* currentUrl;
    NSURL* clippedUrl;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIWebView *webViewBack;
@property (strong, nonatomic) IBOutlet UIWebView *webViewFore;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UISwitch *switchIsClipping;

- (void)webViewDidFinishLoad2:(UIWebView *)sender;
- (void)check;
- (IBAction)urlCheck:(id)sender;
- (void)send:(NSString*)strUrl;
- (void)messageClear;
- (void)clip;

- (void)prepareSignInWithWebView:(UIWebView*)webView;
- (void)signIn:(id)sender;

- (IBAction)goToHomepage:(id)sender;
- (IBAction)toggleSwitchIsClipping:(id)sender;

@end
