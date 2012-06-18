//
//  E5ViewController2.m
//  Ever5sec
//
//  Created by 達郎 植田 on 12/06/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "E5ViewController2.h"

@interface E5ViewController2 ()

@end

@implementation E5ViewController2
@synthesize homepage;
@synthesize userId;
@synthesize password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    userId.text = [[NSUserDefaults standardUserDefaults]
                   objectForKey:@"Ever5secUserIdPrefKey"];
    password.text = [[NSUserDefaults standardUserDefaults]
                     objectForKey:@"Ever5secPasswordPrefKey"];
    password.secureTextEntry = YES;
    homepage.text = [[[NSUserDefaults standardUserDefaults]
                      URLForKey:@"Ever5secHomepagePrefKey"]
                     description];
}

- (void)viewDidUnload
{
    [self setHomepage:nil];
    [self setUserId:nil];
    [self setPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textFieldDidEndEditing:(UITextField *)sender
{
    if (sender == homepage) {
        [[NSUserDefaults standardUserDefaults]
         setURL:[NSURL URLWithString:homepage.text] forKey:@"Ever5secHomepagePrefKey"];
        if( [homepage canResignFirstResponder] ) {
            [homepage resignFirstResponder];   
        }
    } else if (sender == userId) {
        [[NSUserDefaults standardUserDefaults]
         setObject:userId.text forKey:@"Ever5secUserIdPrefKey"];
        NSLog(@"userId.text = %@\n", userId.text);
        NSLog(@"%@\n", [[NSUserDefaults standardUserDefaults] objectForKey:@"Ever5secUserIdPrefKey"]);
        if( [userId canResignFirstResponder] ) {
            [userId resignFirstResponder];   
        }
    } else if (sender == password) {
        [[NSUserDefaults standardUserDefaults]
         setObject:password.text forKey:@"Ever5secPasswordPrefKey"];
        if( [password canResignFirstResponder] ) {
            [password resignFirstResponder];   
        }
    }
}

- (void)textFieldShouldReturn:(UITextField *)sender
{
    if (sender == homepage) {
        [[NSUserDefaults standardUserDefaults]
         setURL:[NSURL URLWithString:homepage.text] forKey:@"Ever5secHomepagePrefKey"];
        if( [homepage canResignFirstResponder] ) {
            [homepage resignFirstResponder];   
        }
    } else if (sender == userId) {
        [[NSUserDefaults standardUserDefaults]
         setObject:userId.text forKey:@"Ever5secUserIdPrefKey"];
        NSLog(@"userId.text = %@\n", userId.text);
        NSLog(@"%@\n", [[NSUserDefaults standardUserDefaults] objectForKey:@"Ever5secUserIdPrefKey"]);
        if( [userId canResignFirstResponder] ) {
            [userId resignFirstResponder];   
        }
    } else if (sender == password) {
        [[NSUserDefaults standardUserDefaults]
         setObject:password.text forKey:@"Ever5secPasswordPrefKey"];
        if( [password canResignFirstResponder] ) {
            [password resignFirstResponder];   
        }
    }
}

@end
