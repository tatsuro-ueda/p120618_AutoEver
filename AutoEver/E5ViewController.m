//
//  E5ViewController.m
//  Ever5sec
//
//  Created by 達郎 植田 on 12/06/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "E5ViewController.h"

@interface E5ViewController ()

@end

NSString* const Ever5secIsSecondOrLaterLaunch = @"Ever5secIsSecondOrLaterLaunch";
NSString* const Ever5secIsClippingPrefKey = @"Ever5secIsClippingPrefKey";
float const floatDelaySeconds = 5.0;

@implementation E5ViewController
@synthesize searchBar;
@synthesize webViewBack;
@synthesize webViewFore;
@synthesize message;
@synthesize switchIsClipping;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 起動時のみバックグラウンドでEvernoteにログイン
    if ([[NSUserDefaults standardUserDefaults] 
         boolForKey:@"Ever5secIsJustLaunchedPrefKey"] == YES) {
        [self prepareSignIn:webViewBack];
        [[NSUserDefaults standardUserDefaults] 
         setBool:NO forKey:@"Ever5secIsJustLaunchedPrefKey"];
    }
    
    // ホームページへジャンプ
    [self goToHomepage:nil];
    
    // 初回起動時は設定をうながす
    if ([[NSUserDefaults standardUserDefaults] boolForKey:Ever5secIsSecondOrLaterLaunch] != YES) {
        UIAlertView* alertFirstTime =
        [[UIAlertView alloc] 
         initWithTitle:@"Notice" 
         message:@"At first, please input the Evernote account setting."
         delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil];
        [alertFirstTime show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Ever5secIsSecondOrLaterLaunch];
    }
    
    // 自動クリップ抑制を解除する
    isClipping = NO;
    
    // 自動クリップのスイッチの状態を読み出す
    switchIsClipping.on = [[NSUserDefaults standardUserDefaults]
                           boolForKey:Ever5secIsClippingPrefKey];
}

- (void)viewDidUnload
{
    [self setWebViewBack:nil];
    [self setSearchBar:nil];
    [self setWebViewFore:nil];
    [self setMessage:nil];
    [self setSwitchIsClipping:nil];
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
    //message.text = @"## Loaded ##";
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    if (switchIsClipping.on == YES && isClipping == NO) {
        currentUrl = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        isClipping = YES;
        NSLog(@"Automatic clip started.");
        //[self performSelector:@selector(check) withObject:nil afterDelay:floatDelaySeconds];
        [self performSelector:@selector(check) withObject:nil];
    }
}

- (void)webViewDidFinishLoad2:(UIWebView *)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [searchBar setText:[webViewFore.request.URL description]];
    //message.text = @"## Loaded ##";
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    //if (switchIsClipping.on == YES && isClipping == NO) {
    if (switchIsClipping.on == YES && isClipping == NO) {
        currentUrl = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        isClipping = YES;
        NSLog(@"Automatic clip started.");
        //[self performSelector:@selector(check) withObject:nil afterDelay:floatDelaySeconds];
        [self performSelector:@selector(check) withObject:nil];
    }
}

- (void)check {
        // URLがgoogleを含んでいるかチェックする
        NSLog(@"google checking...");
        NSString* urlString = [webViewFore.request.URL description];
        NSRange match = [urlString rangeOfString:@"google"];
        
        // 含む場合は何もしない
        if (match.location != NSNotFound) {
            NSLog(@"URL contains google");
            // URLがgwtのものかチェックする
            NSString* strUrl = [webViewFore.request.URL description];
            NSRange match = [strUrl rangeOfString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F"];
            
            // 例外：gwtのものの場合1ページ目かどうかをチェックする
            if (match.location != NSNotFound) {
                NSLog(@"URL contains gwt");
                match = [strUrl rangeOfString:@"&wsi="];
                if (match.location != NSNotFound) {
                    NSLog(@"URL contains &wsi");
                    isClipping = NO;
                } else {
                    NSLog(@"URL OK");
                    //[self urlCheck:nil];
                    [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
                }
            } else {
                NSLog(@"Clip process ended.");
                isClipping = NO;
                [self prepareSignIn:webViewBack];
            }
        } else {
            
            // 含まない場合は、即時クリップを行う
            //[self urlCheck:nil];
            [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
        }
}

- (IBAction)urlCheck:(id)sender;
{
    // 自動クリップは移動したら行われない。クリップしたURLを再度クリップすることもない。
    NSLog(@"webViewFore.request.URL = \n%@", webViewFore.request.URL);
    NSLog(@"currentUrl = \n%@", currentUrl);
    NSLog(@"clippedUrl = \n%@", clippedUrl);
    NSLog(@"checking current URL...");
    if (webViewFore.request.URL == currentUrl && !([[webViewFore.request.URL description] isEqualToString: [clippedUrl description]])) {
        
        // URLがgwtのものかチェックする
        NSString* strUrl = [webViewFore.request.URL description];
        NSRange match = [strUrl rangeOfString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F"];
        
        // gwtのものの場合は置換する
        if (match.location != NSNotFound) {
            NSLog(@"URL contains gwt");
            
            NSString *template = @"http://$2";
            NSRegularExpression *regexp =
            [NSRegularExpression regularExpressionWithPattern:@"(http://www\.google\.com/gwt/x.source=reader&u=http%3A%2F%2F)(.*)"
                                                      options:0
                                                        error:nil];
            
            NSString *replaced =
            [regexp stringByReplacingMatchesInString:strUrl
                                             options:0
                                               range:NSMakeRange(0,strUrl.length)
                                        withTemplate:template];
            
            NSRange match = [replaced rangeOfString:@"%2F"];
            while (match.location != NSNotFound){
                NSString *string = replaced;
                NSString *template = @"$1/$2";
                NSRegularExpression *regexp =
                [NSRegularExpression regularExpressionWithPattern:@"(.*)%2F(.*)" options:0 error:nil];
                replaced = [regexp stringByReplacingMatchesInString:string
                                                            options:0
                                                              range:NSMakeRange(0, string.length)
                                                       withTemplate:template];
                match = [replaced rangeOfString:@"%2F"];
            }
            
            // URLを書きかえる
            strUrl = replaced;
        }
        
        [self send:strUrl];
    } else {
        isClipping = NO;
        NSLog(@"You moved or already clipped URL");
        [self performSelector:@selector(webViewDidFinishLoad2:) withObject:self];
    }
}

// 即時クリップのボタンを押すと実行される
- (void)send:(NSString*)strUrl;
{
    // 表のWebViewのページを裏のWebViewで呼び出す
    [webViewBack loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:strUrl]]];
    
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
    isClipping = NO;
    [self performSelector:@selector(clip) withObject:nil afterDelay:5.0];
}

- (void)clip {
    
    // 裏のWebViewでクリップのJavaScriptを実行する
    [webViewBack stringByEvaluatingJavaScriptFromString:
     @"window.location='http://s.Evernote.com/grclip?url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)"];
    NSLog(@"Clipped\n");
    clippedUrl = webViewBack.request.URL;
}

#pragma mark - other processes

- (void)prepareSignIn:(id)sender {
    NSLog(@"Sign in page loading...");
    [sender loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:@"http://www.evernote.com/Home.action"]]];
    
    [self performSelector:@selector(signIn:) withObject:sender afterDelay:8.0];
}

- (void)signIn:(id)sender {
    
    // 設定を読み出す
    NSString* userId = [[NSUserDefaults standardUserDefaults] 
                        objectForKey:@"Ever5secUserIdPrefKey"];
    NSString* password = [[NSUserDefaults standardUserDefaults] 
                          objectForKey:@"Ever5secPasswordPrefKey"];
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

- (IBAction)goToHomepage:(id)sender {
    urlHomepage = [[NSUserDefaults standardUserDefaults]
                   URLForKey:@"Ever5secHomepagePrefKey"];
    if (urlHomepage == nil) {
        urlHomepage = [NSURL URLWithString:@"http://www.google.co.uk"];
    }
    [webViewFore loadRequest:
     [NSURLRequest requestWithURL:urlHomepage]];
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
}

@end