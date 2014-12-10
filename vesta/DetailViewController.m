//
//  DetailViewController.m
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "DetailViewController.h"
#import "LoginViewController.h"
#import "SJUser.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailCartoparty:(SJCartoparty *)newDetailCartoparty {
    if (_detailCartoparty != newDetailCartoparty) {
        _detailCartoparty = newDetailCartoparty;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailCartoparty) {
        self.detailDescriptionLabel.text = [self.detailCartoparty _description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    SJUser *loggedUser = [SJUser sharedManager];
    if ([loggedUser accessToken] == nil && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginViewController.modalTransitionStyle = UIModalPresentationFormSheet;
        loginViewController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:loginViewController animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
