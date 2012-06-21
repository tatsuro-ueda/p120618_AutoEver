//
//  AEViewController.m
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AEMainViewController.h"
#import "AEConst.h"
#import "AEWebViewBack.h"

@interface AEMainViewController ()

@end

float const floatDelaySeconds = 5.0;

@implementation AEMainViewController
@synthesize searchBar;
@synthesize webViewBack;
@synthesize webViewFore;
@synthesize switchIsClipping;
@synthesize actIndicator;
@synthesize actIndicatorBack;
@synthesize blockingAutoClip;
@synthesize urlAlreadyClipped;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 起動時のみバックグラウンドでEvernoteにログイン
    if ([[NSUserDefaults standardUserDefaults] 
         boolForKey:Ever5secIsJustLaunchedPrefKey] == YES) {
        [webViewBack prepareSignIn];
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
    blockingAutoClip = NO;
    
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
    actIndicatorBack.hidden = YES;
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    if (switchIsClipping.on == YES && blockingAutoClip == NO) {
        urlAutoClipDidStart = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        blockingAutoClip = YES;
        NSLog(@"Automatic clip started.");
        [self performSelector:@selector(check) withObject:nil];
    }
}

// 自動クリップが終了したら呼び出される。ループになっている。
- (void)webViewDidFinishLoad2:(UIWebView *)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [searchBar setText:[webViewFore.request.URL description]];
    
    // 自動クリップがオンになっている、かつ、クリップ中ではない
    if (switchIsClipping.on == YES && blockingAutoClip == NO) {
        urlAutoClipDidStart = webViewFore.request.URL;
        
        // クリップ中である。このあいだは自動クリップは行われない。
        blockingAutoClip = YES;
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
        if ([self URLContainString:@"google" withUrl:webViewFore.request.URL]) {
            
            // URLがgwtのものかチェックする
            if ([self URLContainString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F" withUrl:webViewFore.request.URL]) {
                NSLog(@"URL contains gwt");

                // gwtのものの場合
                if ([self URLContainString:@"&wsi=" withUrl:webViewFore.request.URL]) {

                    // 2ページ以降であれば何もしない
                    NSLog(@"URL contains &wsi");
                    blockingAutoClip = NO;
                } else {
                    
                    // 1ページ目であればクリップする
                    NSLog(@"URL OK");
                    [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
                }
            } else {
                NSLog(@"Clip process ended.");
                blockingAutoClip = NO;
                [webViewBack prepareSignIn];
            }
        }
        else {
            // 含まない場合は、即時クリップを行う
            [self performSelector:@selector(urlCheck:) withObject:nil afterDelay:floatDelaySeconds];
        }
    } else {
        NSLog(@"You moved or already clipped URL");
        blockingAutoClip = NO;
        [self performSelector:@selector(webViewDidFinishLoad2:) withObject:self];
    }
}

// URLがstringを含んでいるかチェックする
- (BOOL)URLContainString:(NSString*)string withUrl:(NSURL*)url
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
    NSURL* url = webViewFore.request.URL;
    // URLがgwtのものかチェックする
    if ([self URLContainString:@"http://www.google.com/gwt/x?source=reader&u=http%3A%2F%2F" 
                       withUrl:webViewFore.request.URL]) {
        
        // gwtのものの場合は置換する
        NSString* strUrl = [url description];
        NSLog(@"URL contains gwt");
        strUrl = [self stringBeDeletedGwtUrlFromString:strUrl];
        strUrl = [strUrl stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];            
        NSLog(@"strUrl = %@", strUrl);
        url = [NSURL URLWithString:strUrl];
    }

    // 任意クリップが行われたら自動クリップを止める
    NSLog(@"urlCheck");
    NSLog(@"url = \n%@", url);
    NSLog(@"urlAlreadyClipped = \n%@", urlAlreadyClipped);
    if([url isEqual:urlAlreadyClipped]) {
        blockingAutoClip = NO;
    }
    else {
        [webViewBack sendURL:url withSender:self];
    }
}

#pragma mark - other processes

- (IBAction)goToHomepage:(id)sender {
    urlHomepage = [[NSUserDefaults standardUserDefaults]
                   URLForKey:Ever5secHomepagePrefKey];
    if (urlHomepage == nil) {
        urlHomepage = [NSURL URLWithString:@"http://www.google.com"];
    }
    [webViewFore loadRequest:
     [NSURLRequest requestWithURL:urlHomepage]];
    [webViewBack prepareSignIn];
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

@end