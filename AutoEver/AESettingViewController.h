//
//  AESettingViewController.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AESettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userId;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *homepage;

- (void)textFieldDidEndEditing:(UITextField *)sender;
- (void)textFieldShouldReturn:(UITextField *)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)setCurrentPageAsHomepage:(id)sender;
- (IBAction)setGoogleReaderAsHomepage:(id)sender;

@end
