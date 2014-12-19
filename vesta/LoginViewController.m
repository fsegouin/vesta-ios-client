//
//  LoginViewController.m
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>
#import <KVNProgress/KVNProgress.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SJUser.h"
#import "NSString+FontAwesome.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    DEBUG
    
    self.loginTextField.text = @"test0@test.fr";
    self.passwordTextField.text = @"test";
    
    // Make sure the keyboard is dismissed when we tap outside
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Same thing when we hit the 'return' key
    [self.loginTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
    
    // Style our login form
    self.rightArrow.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
    self.rightArrow.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-right"];
    
    self.loginButton.clipsToBounds = YES;
    self.loginButton.layer.cornerRadius = 20;
    self.signupButton.clipsToBounds = YES;
    self.signupButton.layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionLoginWithCredentials:(id)sender {
    
    // Define the load success block for the SJUser loginWithEmail message
    void (^loadSuccessBlock)(LBAccessToken *) = ^(LBAccessToken *token) {
        
        // Dismiss progress HUD
        [KVNProgress dismiss];
        
        NSLog(@"Successfully logged in for user %@ with accessToken: %@", [token userId], [token _id]);
        SJUser *loggedUser = [SJUser sharedManager];
        [loggedUser setAccessToken:[token _id]];
        [loggedUser setUserId:[token userId]];
        [self dismissViewControllerAnimated:NO completion:nil];
    };//end selfSuccessBlock
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        
        // Dismiss progress HUD
        [KVNProgress dismiss];
        
        NSLog(@"Error %@", error.description);
        NSLog(@"userInfo error : %@", error.userInfo);
        
        NSString *localizedDescriptionError = [[error userInfo] valueForKey:@"NSLocalizedDescription"];
        NSString *errorMessage = [NSString string];
        
        if ([localizedDescriptionError rangeOfString:@"401"].location == NSNotFound) {
            errorMessage = localizedDescriptionError;
        } else {
            errorMessage = @"Vérifiez vos informations de connexion";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                        message:errorMessage
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
    
    // Show a progress HUD
    [KVNProgress show];
    
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
////     Get the new view controller using [segue destinationViewController].
////     Pass the selected object to the new view controller.
//}


@end
