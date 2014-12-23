//
//  SignupViewController.h
//  vesta
//
//  Created by Florent Segouin on 23/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LoopBack/LBAccessToken.h>
#import <LoopBack/LBUser.h>
#import "FDTakeController.h"

@interface SignupViewController : UIViewController

@property (weak, nonatomic  ) IBOutlet UIButton    *actionDismiss;
@property (strong, nonatomic) IBOutlet UIButton    *actionSignup;
@property (strong, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property FDTakeController *takeController;

- (IBAction)takePhotoOrChooseFromLibrary:(id)sender;
- (IBAction)uploadProfilePicture:(id)sender;

@end
