//
//  AEWebViewBack.m
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AEWebViewBack.h"
#import "AEConst.h"

@implementation AEWebViewBack

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// 即時クリップのボタンを押すと実行される
- (void)sendURL:(NSURL*)url withSender:(id)sender;
{
    mainViewController = sender;
    
    // 表のWebViewのページを裏のWebViewで呼び出す
    [self loadRequest:
     [NSURLRequest requestWithURL:url]];
    
    // 「Clip success」のメッセージを表示する
    alertClipped =
    [[UIAlertView alloc] initWithTitle:@"Clip" message:@""
                              delegate:self 
                     cancelButtonTitle:@"success" 
                     otherButtonTitles:nil];
    [alertClipped show];
    
    // 0.3秒後にメッセージを消す
    [self performSelector:@selector(messageClear) withObject:nil afterDelay:0.3];
}

- (void)messageClear {
    [alertClipped dismissWithClickedButtonIndex:0 animated:NO];
    
    // 自動クリップ抑制を解除する
    mainViewController.blockingAutoClip = NO;

    // 同じページを繰り返しクリップしないようにする
    mainViewController.urlAlreadyClipped = self.request.URL;

    [self performSelector:@selector(clip) withObject:nil afterDelay:5.0];
}

- (void)clip {
    
    // Evernoteログインページであればreturnする
    if ([self isContainString:@"https://www.evernote.com/Home.action?" 
                      withUrl:self.request.URL]) {
        NSLog(@"Stop clipping Evernote login page.");
        return;
    }
    
    // 裏のWebViewでクリップのJavaScriptを実行する
    [self stringByEvaluatingJavaScriptFromString:
     @"window.location='http://s.Evernote.com/grclip?url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)"];
    NSLog(@"Clipped: %@", self.request.URL);
}

// URLがstringを含んでいるかチェックする
// AEMainViewControllerの同名関数と同じ
- (BOOL)isContainString:(NSString*)string withUrl:(NSURL*)url
{
    NSLog(@"Checking URL contains %@...", string);
    NSString* urlString = [url description];
    NSRange match = [urlString rangeOfString:string];
    
    if (match.location != NSNotFound) {
        NSLog(@"URL contains %@", string);
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prepareSignIn {
    NSLog(@"Sign in page loading...");
    [self loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:@"http://www.evernote.com/Home.action"]]];
    
    [self performSelector:@selector(signIn:) withObject:self afterDelay:8.0];
}

- (void)signIn:(id)sender {
    
    // 設定を読み出す
    NSString* userId = [[NSUserDefaults standardUserDefaults] 
                        objectForKey:Ever5secUserIdPrefKey];
    NSString* password = [[NSUserDefaults standardUserDefaults] 
                          objectForKey:Ever5secPasswordPrefKey];
    
    if (userId != nil && password != nil) {
        NSString* script = [@"javascript:document.login_form.username.value='" 
                            stringByAppendingString:userId];
        
        // JaveScriptを生成する
        script = [script stringByAppendingString:@"';document.login_form.password.value='"];
        script = [script stringByAppendingString:password];
        script = [script stringByAppendingString:@"';document.login_form.login.click();"];
        //NSLog(@"userID: %@, script: %@", userId, script);
        
        [self stringByEvaluatingJavaScriptFromString:script];
        NSLog(@"Sign in JavaScript was performed.");
    }
}

@end
