//
//  AEWebViewBack.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEMainViewController.h"

@class AEMainViewController;

@interface AEWebViewBack : UIWebView{
    UIAlertView* alertClipped;
    AEMainViewController* mainViewController;
}

- (void)sendURL:(NSURL*)url withSender:(id)sender;
- (void)messageClear;
- (void)clip;
- (void)prepareSignIn;
- (void)signIn:(id)sender;

@end
