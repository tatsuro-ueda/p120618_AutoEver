//
//  AEViewController.m
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AEViewController.h"
#import "AEConst.h"

@interface AEViewController ()

@end

float const floatDelaySeconds = 5.0;

@implementation AEViewController
@synthesize searchBar;
@synthesize webViewBack;
@synthesize webViewFore;
@synthesize switchIsClipping;
@synthesize actIndicator;
@synthesize actIndicatorBack;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 起動時のみバックグラウンドでEvernoteにログイン
    if ([[NSUserDefaults standardUserDefaults] 
         boolForKey:Ever5secIsJustLaunchedPrefKey] == YES) {
        [self prepareSignInWithWebView:webViewBack];
        [[NSUserDefaults standardUserDefaults] 
         setBool:NO forKey:Ever5secIsJustLaunchedPrefKey];
    }
    
    // ホームページへジャンプ
    [self goToHomepage:nil];
    
    // 初回起動時は設定をうながす
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Ever5secIsSecondOrLaterLaunch] != YES) {
        UIAlertView* alertFirstTime =
        [[UIAlertView alloc] 
         initWithTitle:@"Notice" 
         message:@"At first, please input the Evernote account information in Setting page (Gear icon)."
         delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil];
        [alertFirstTime show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Ever5secIsSecondOrLaterLaunch];
    }
    
    // 自動クリップ抑制を解除する
    isBlockingAutoClip = NO;
    
    // 自動クリップのスイッチの状態を読み出す
    switchIsClipping.on = [[NSUserDefaults standardUserDefaults]
                           boolForKey:Ever5secIsClippingPrefKey];
}

- (void)viewDidUnload
{
    [self setWebViewBack:nil];
    [self setSearchBar:nil];
    [self setWebViewFore:nil];
    [self setSwitchIsClipping:nil];
    [self setActIndicator:nil];
    [self setActIndicatorBack:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - clip process

- (void)webViewDidFinishLoad:(UIWebView *)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [searchBar setText:[webViewFore.request.URL description]];
    [actIndicator stopAnimating];
    actIndicatorBack.hidden = YES ;
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    if (switchIsClipping.on == YES && isBlockingAutoClip == NO) {
        urlAutoClipDidStart = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        isBlockingAutoClip = YES;
        NSLog(@"Automatic clip started.");
        [self performSelector:@selector(check) withObject:nil];
    }
}

// 自動クリップが終了したら呼び出される。ループになっている。
- (void)webViewDidFinishLoad2:(UIWebView *)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [searchBar setText:[webViewFore.request.URL description]];
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    if (switchIsClipping.on == YES && isBlockingAutoClip == NO) {
        urlAutoClipDidStart = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        isBlockingAutoClip = YES;
        NSLog(@"Automatic clip started.");
        [self performSelector:@selector(check) withObject:nil];
    }
}

- (void)check {
    // 自動クリップは移動したら行われない。クリップしたURLを再度クリップすることもない。
    NSLog(@"webViewFore.request.URL = \n%@", webViewFore.request.URL);
    NSLog(@"urlAutoClipDidStart = \n%@", urlAutoClipDidStart);
    NSLog(@"urlAlreadyClipped = \n%@", urlAlreadyClipped);
    NSLog(@"checking current URL...");
    if ([webViewFore.request.URL isEqual:urlAutoClipDidStart] && 
        !([webViewFore.request.URL isEqual: urlAlreadyClipped])) {

        // URLがgoogleを含んでいるかチェックする
        if ([self isContainString:@"google" withUrl:webViewFore.request.URL]) {
            // URLがgwtのものかチェックする
            NSString* strUrl = [webViewFore.request.URL description];
            NSRange match = [strUrl rangeOfString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F"];
            
            // 例外：gwtのものの場合1ページ目かどうかをチェックする
            if (match.location != NSNotFound) {
                NSLog(@"URL contains gwt");
                match = [strUrl rangeOfString:@"&wsi="];
                if (match.location != NSNotFound) {
                    NSLog(@"URL contains &wsi");
                    isBlockingAutoClip = NO;
                } else {
                    NSLog(@"URL OK");
                    [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
                }
            } else {
                NSLog(@"Clip process ended.");
                isBlockingAutoClip = NO;
                [self prepareSignInWithWebView:webViewBack];
            }
        }
        else {
            // 含まない場合は、即時クリップを行う
            [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
        }
    } else {
        isBlockingAutoClip = NO;
        NSLog(@"You moved or already clipped URL");
        [self performSelector:@selector(webViewDidFinishLoad2:) withObject:self];
    }
}

// URLがstringを含んでいるかチェックする
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

- (IBAction)urlCheck:(id)sender;
{
        
    // URLがgwtのものかチェックする
    NSString* strUrl = [webViewFore.request.URL description];
    NSRange match = [strUrl rangeOfString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F"];
    
    // gwtのものの場合は置換する
    if (match.location != NSNotFound) {
        NSLog(@"URL contains gwt");
        
        strUrl = [self stringBeDeletedGwtUrlFromString:strUrl];
        
        strUrl = [strUrl stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];            
        
        NSLog(@"strUrl = %@", strUrl);
    }
    
    [self send:strUrl];
}

// 即時クリップのボタンを押すと実行される
- (void)send:(NSString*)strUrl;
{
    // 表のWebViewのページを裏のWebViewで呼び出す
    [webViewBack loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:strUrl]]];
    
    // Evernoteログインページであればbreakする
    if ([self isContainString:@"https://www.evernote.com/Home.action?" 
                      withUrl:webViewBack.request.URL]) {
        NSLog(@"Stop clipping Evernote login page.");
        return;
    }
         
    // 「Clip success」のメッセージを表示する
    alertClipped =
    [[UIAlertView alloc] initWithTitle:@"Clip" message:@""
                              delegate:self cancelButtonTitle:@"success" otherButtonTitles:nil];
    [alertClipped show];
    
    // 0.3秒後にメッセージを消す
    [self performSelector:@selector(messageClear) withObject:nil afterDelay:0.3];
}

- (void)messageClear {
    [alertClipped dismissWithClickedButtonIndex:0 animated:NO];
    
    // 自動クリップ抑制を解除する
    isBlockingAutoClip = NO;
    [self performSelector:@selector(clip) withObject:nil afterDelay:5.0];
}

- (void)clip {
    
    // 裏のWebViewでクリップのJavaScriptを実行する
    [webViewBack stringByEvaluatingJavaScriptFromString:
     @"window.location='http://s.Evernote.com/grclip?url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)"];
    NSLog(@"Clipped: %@", webViewBack.request.URL);
    
    // 同じページを繰り返しクリップしないようにする
    urlAlreadyClipped = webViewBack.request.URL;
}

#pragma mark - other processes

- (void)prepareSignInWithWebView:(UIWebView*)webView {
    NSLog(@"Sign in page loading...");
    [webView loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:@"http://www.evernote.com/Home.action"]]];
    
    [self performSelector:@selector(signIn:) withObject:webView afterDelay:8.0];
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
        
        [sender stringByEvaluatingJavaScriptFromString:script];
        NSLog(@"Sign in JavaScript was performed.");
    }
}

- (IBAction)goToHomepage:(id)sender {
    urlHomepage = [[NSUserDefaults standardUserDefaults]
                   URLForKey:Ever5secHomepagePrefKey];
    if (urlHomepage == nil) {
        urlHomepage = [NSURL URLWithString:@"http://www.google.com"];
    }
    [webViewFore loadRequest:
     [NSURLRequest requestWithURL:urlHomepage]];
    [self prepareSignInWithWebView:webViewBack];
}

- (IBAction)toggleSwitchIsClipping:(id)sender {
    [[NSUserDefaults standardUserDefaults]
     setBool:switchIsClipping.on forKey:Ever5secIsClippingPrefKey];    
}

- (void)searchBarSearchButtonClicked: (UISearchBar *) sender {
    [searchBar resignFirstResponder];
    printf("Search Bar resign First Responder\n");
    [webViewFore loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:searchBar.text]]];
}

- (void)webViewDidStartLoad:(UIWebView *)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [searchBar setText:[webViewFore.request.URL description]];
    [actIndicator startAnimating];
    actIndicatorBack.hidden = NO ;
}

- (NSString*)stringBeDeletedGwtUrlFromString:(NSString*)strUrl{
    NSString *template = @"$2";
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:@"(http://www\.google\.com/gwt/x.source=reader&u=)(.*)"
                                              options:0 
                                                error:nil];
    strUrl =
    [regexp stringByReplacingMatchesInString:strUrl
                                     options:0
                                       range:NSMakeRange(0,strUrl.length)
                                withTemplate:template];
    return strUrl;
}
- (NSString*)processEscapeString:(NSString*)strEsc withPattern:(NSString*)strPattern inString:(NSString*)strText{
    NSRange match = [strText rangeOfString:strEsc];
    while (match.location != NSNotFound){
        NSString *string = strText;
        NSString *template = @"$1/$2";
        NSRegularExpression *regexp =
        [NSRegularExpression regularExpressionWithPattern:strPattern options:0 error:nil];
        strText = [regexp stringByReplacingMatchesInString:string
                                                    options:0
                                                      range:NSMakeRange(0, string.length)
                                               withTemplate:template];
        match = [strText rangeOfString:strEsc];
    }    
    return strText;
}

@end