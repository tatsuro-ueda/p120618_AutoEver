//
//  AEUsageViewController.m
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AEUsageViewController.h"

@interface AEUsageViewController ()

@end

@implementation AEUsageViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismiss:(id)sender {
     [self dismissModalViewControllerAnimated:YES];
}
@end
