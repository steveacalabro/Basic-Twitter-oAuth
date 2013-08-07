//
//  ViewController.m
//  oAuth
//
//  Created by Steve Calabro on 5/22/13.
//  Copyright (c) 2013
//

#import "ViewController.h"

#define ERROR_TITLE_MSG @"ERROR"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_OK @"OK"

@interface ViewController ()
    //Twitter Stuff
    @property (nonatomic, strong) ACAccountStore *accountStore;
    @property (nonatomic, strong) TWAPIManager *apiManager;
    @property (nonatomic, strong) NSArray *accounts;
@end

@implementation ViewController

    //---------------------------------------------------------------
    // App Setup
    //---------------------------------------------------------------
    - (void)viewDidLoad
    {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
 
        //twitter stuff
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    }

    - (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    - (IBAction)oAuth:(id)sender
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (ACAccount *acct in _accounts) {
            [sheet addButtonWithTitle:acct.username];
        }
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
        [sheet showInView:self.view];
        // This will set the Label Fields
        //self.oAuthKey.text = @"Generated Key";
        //self.oAuthSecret.text = @"Generated Secret";
        
    }
    //---------------------------------------------------------------
    // Twitter Stuff
    //---------------------------------------------------------------
    - (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        [self refreshTwitterAccounts];
    }
    - (void)dealloc
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
                //NSLog(responseData);
                if (responseData) {
                    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    
                    NSArray* vars = [responseStr componentsSeparatedByString: @"&"];
                    
                    NSString* key = [vars objectAtIndex: 0];
                    NSString *authKey= [key substringFromIndex:12];
                    
                    NSString *secret = [vars objectAtIndex: 1];
                    NSString *authSecret= [secret substringFromIndex:19];
                    
                    NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                    NSString *lined = [parts componentsJoinedByString:@"\n"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.oAuthKey.text = authKey;
                        self.oAuthSecret.text = authSecret;
                    });
                }
                else {
                  // NSlog(@"Reverse Auth process failed. Error returned was:");
                }
            }];
        }
    }
    - (void)refreshTwitterAccounts
    {
        //NSlog(@"Refreshing Twitter Accounts");
        if (![TWAPIManager isLocalTwitterAccountAvailable]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        _oAuthButton.enabled = YES;
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                        [alert show];
                        //NSLog(@"You were not granted access to the Twitter accounts.");
                    }
                });
            }];
        }
    }

    - (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
    {
        ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
            if (granted) {
                self.accounts = [_accountStore accountsWithAccountType:twitterType];
            }
            
            block(granted);
        };
        
        //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
        if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
            [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
        }
        else {
            [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
        }
    }

    /**
     *  Handles the button press that initiates the token exchange.
     *
     *  We check the current configuration inside -[UIViewController viewDidAppear].
     */
    - (void)performReverseAuth:(id)sender
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (ACAccount *acct in _accounts) {
            [sheet addButtonWithTitle:acct.username];
        }
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
        [sheet showInView:self.view];
    }




@end
