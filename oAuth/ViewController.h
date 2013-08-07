//
//  ViewController.h
//  oAuth
//
//  Created by Steve Calabro on 5/22/13.
//  Copyright (c) 2013
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TWAPIManager.h"

//---------------------------------------------------------------
// App Setup
//---------------------------------------------------------------
@interface ViewController : UIViewController <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *oAuthButton;
@property (weak, nonatomic) IBOutlet UILabel *oAuthKey;
@property (weak, nonatomic) IBOutlet UILabel *oAuthSecret;

- (IBAction)oAuth:(id)sender;
- (void)performReverseAuth:(id)sender;

@end
