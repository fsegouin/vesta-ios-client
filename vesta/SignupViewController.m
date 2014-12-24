//
//  SignupViewController.m
//  vesta
//
//  Created by Florent Segouin on 23/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "SignupViewController.h"
#import "SJUser.h"
#import "FDTakeController.h"
#import "UIColor+FlatUI.h"
#import "AFNetworking.h"
#import "KVNProgress.h"
#import "UIImage+Resizing.h"

@interface SignupViewController () <FDTakeDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    self.takeController.allowsEditingPhoto = YES;
    
    // Make sure the keyboard is dismissed when we tap outside
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Same thing when we hit the 'return' key
    [self.emailTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
    [self.firstnameTextField setDelegate:self];
    [self.lastnameTextField setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotoOrChooseFromLibrary:(id)sender {
    [self.takeController takePhotoOrChooseFromLibrary];
}

- (IBAction)uploadProfilePicture:(id)sender {
    BOOL isEmailValid = [self validEmail:self.emailTextField.text];
    
    if (!isEmailValid) {
        [KVNProgress showErrorWithStatus:@"Votre email doit être valide pour continuer"];
    }
    else if (self.passwordTextField.text.length < 4) {
        [KVNProgress showErrorWithStatus:@"Votre mot de passe doit contenir au moins 4 caractères"];
    }
    else if (self.firstnameTextField.text.length == 0) {
        [KVNProgress showErrorWithStatus:@"Vous avez oublié votre prénom ?"];
    }
    else if (self.lastnameTextField.text.length == 0) {
        [KVNProgress showErrorWithStatus:@"Vous avez oublié votre nom ?"];
    }
    else {
        [KVNProgress show];
        if (self.cameraImageView.alpha == 1) { // Check if the user took a picture
            NSString *fileName = @"profile_.jpg";
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer             = [AFJSONResponseSerializer serializer];
            
            //        PROD URL
            NSString *urlString = @"http://188.166.54.59:3000/api/photo/";
            
            UIImage* scaledImage  = [self.cameraImageView.image scaleToFitSize:CGSizeMake(500, 500)];
            UIImage* croppedImage = [scaledImage cropToSize:CGSizeMake(500, 500) usingMode:NYXCropModeCenter];
            NSData *imageData     = UIImageJPEGRepresentation(croppedImage, 1.0);
            
            [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success - URL : %@", [responseObject valueForKey:@"file"]);
                [self signupWithProfilePicture:[NSString stringWithFormat:@"http://188.166.54.59:3000%@", [responseObject valueForKey:@"file"]]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failure %@, %@", error, operation.responseString);
                [KVNProgress showErrorWithStatus:@"Impossible de contacter le serveur"];
            }];
        }
        else {
            [self signupWithProfilePicture:@""];
        }
    }
    
}

- (void)signupWithProfilePicture:(NSString *)pictureUrl {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer             = [AFJSONResponseSerializer serializer];
    manager.requestSerializer              = [AFJSONRequestSerializer serializer];
    
    NSString *urlString = @"http://vesta-api.herokuapp.com/api/users/";
    NSDictionary *parameters = @{
                                 @"firstname": self.firstnameTextField.text,
                                 @"lastname": self.lastnameTextField.text,
                                 @"picture": pictureUrl,
//                                 @"username": "",
                                 @"email": self.emailTextField.text,
                                 @"password": self.passwordTextField.text
                                 };
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject != nil) {
            [self getAccessTokenWithCredentials:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [KVNProgress showErrorWithStatus:@"Impossible de contacter le serveur"];
    }];
}

- (void)getAccessTokenWithCredentials:(NSDictionary *)credentials {
    
    // Define the load success block for the SJUser loginWithEmail message
    void (^loadSuccessBlock)(LBAccessToken *) = ^(LBAccessToken *token) {
        
        // Dismiss progress HUD
        [KVNProgress dismiss];
        
        NSLog(@"Successfully logged in for user %@ with accessToken: %@", [token userId], [token _id]);
        
        SJUser *loggedUser = [SJUser sharedManager];
        [loggedUser setAccessToken:[token _id]];
        [loggedUser setUserId:[token userId]];
        
        // Store this token so we can use it later
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[token _id] forKey:@"accessToken"];
        [defaults setObject:[token userId] forKey:@"userId"];
        [defaults synchronize];
        
        [KVNProgress showSuccessWithStatus:@"Inscription réussie"];
        [self dismissToMasterView];
    };//end selfSuccessBlock
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        
        NSLog(@"Error %@", error.description);
        NSLog(@"userInfo error : %@", error.userInfo);
        
        NSString *localizedDescriptionError = [[error userInfo] valueForKey:@"NSLocalizedDescription"];
        NSString *errorMessage = [NSString string];
        
        if ([localizedDescriptionError rangeOfString:@"401"].location == NSNotFound) {
            errorMessage = localizedDescriptionError;
        } else {
            errorMessage = @"Vérifiez vos informations de connexion";
        }
        
        // Show error HUD - auto dismiss
        [KVNProgress showErrorWithStatus:errorMessage];
        
    };//end selfFailblock
    
    //Get a local representation of the 'user' model type
    SJUserRepository *userRepository = (SJUserRepository *)[[AppDelegate adapter] repositoryWithClass:[SJUserRepository class]];
    
    // Invoke the loginWithEmail message for the 'user' SJUser
    // Equivalent http JSON endpoint request : http://localhost:3000/users/login
    
    [userRepository loginWithEmail:[credentials valueForKey:@"email"] password:self.passwordTextField.text success:loadSuccessBlock failure:loadErrorBlock];
    
}

- (void)dismissToMasterView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissAllViewControllers" object:self];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Check form values

-(BOOL)validEmail:(NSString*)emailString {
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    self.cameraImageView.layer.cornerRadius = self.cameraImageView.frame.size.width/2;
    [self.cameraImageView setAlpha:1];
    self.cameraImageView.layer.borderWidth = 2.0f;
    self.cameraImageView.layer.borderColor = [UIColor colorFromHexCode:@"ecf0f1"].CGColor;
    [self.cameraImageView setImage:photo];
}

- (void)viewDidUnload {
    [self setCameraImageView:nil];
    [super viewDidUnload];
}

@end
