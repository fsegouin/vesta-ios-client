//
//  LoginViewController.m
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SJUser.h"
#import "NSString+FontAwesome.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Style our login form
    self.rightArrow.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
    self.rightArrow.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-right"];
    
    self.loginButton.clipsToBounds = YES;
    self.loginButton.layer.cornerRadius = 24;
    self.signupButton.clipsToBounds = YES;
    self.signupButton.layer.cornerRadius = 24;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionLoginWithCredentials:(id)sender {
    
    // Define the load success block for the SJUser loginWithEmail message
    void (^loadSuccessBlock)(LBAccessToken *) = ^(LBAccessToken *token) {
        NSLog(@"Successfully logged in for user %@ with accessToken: %@", [token userId], [token _id]);
        SJUser *loggedUser = [SJUser sharedManager];
        [loggedUser setAccessToken:[token _id]];
        [loggedUser setUserId:[token userId]];
        [self dismissViewControllerAnimated:NO completion:nil];
    };//end selfSuccessBlock
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };//end selfFailblock
    
    //Get a local representation of the 'user' model type
    SJUserRepository *userRepository = (SJUserRepository *)[[AppDelegate adapter] repositoryWithClass:[SJUserRepository class]];
    
    // Invoke the loginWithEmail message for the 'user' SJUser
    // Equivalent http JSON endpoint request : http://localhost:3000/users/login
    
    [userRepository loginWithEmail:self.loginTextField.text password:self.passwordTextField.text success:loadSuccessBlock failure:loadErrorBlock];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
////     Get the new view controller using [segue destinationViewController].
////     Pass the selected object to the new view controller.
//}


@end
