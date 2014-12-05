//
//  LoginViewController.h
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LoopBack/LBAccessToken.h>
#import <LoopBack/LBUser.h>

@interface LoginViewController : UIViewController
- (IBAction)actionLoginWithCredentials:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *rightArrow;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@end
