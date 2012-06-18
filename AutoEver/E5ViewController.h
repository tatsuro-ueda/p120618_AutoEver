//
//  E5ViewController.h
//  Ever5sec
//
//  Created by 達郎 植田 on 12/06/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E5ViewController : UIViewController{
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

- (IBAction)urlCheck:(id)sender;
- (void)send:(NSString*)strUrl;
- (void)check;
- (void)clip;
- (void)signIn:(id)sender;
- (IBAction)goToHomepage:(id)sender;
- (IBAction)toggleSwitchIsClipping:(id)sender;
- (void)messageClear;
- (void)webViewDidFinishLoad2:(UIWebView *)sender;

@end
