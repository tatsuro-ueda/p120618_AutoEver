//
//  AESettingViewController.h
//  AutoEver
//
//  Created by 達郎 植田 on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AESettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *homepage;
@property (strong, nonatomic) IBOutlet UITextField *userId;
@property (strong, nonatomic) IBOutlet UITextField *password;

- (void)textFieldDidEndEditing:(UITextField *)sender;
- (void)textFieldShouldReturn:(UITextField *)sender;

@end
