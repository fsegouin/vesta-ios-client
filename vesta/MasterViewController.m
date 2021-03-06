//
//  MasterViewController.m
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#include <stdlib.h>

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "CartopartyDetailTableViewController.h"
#import "LoginViewController.h"
#import "CartopartiesListTableViewController.h"
#import "SJUser.h"
#import "SJCartoparty.h"
#import "SJCartopartyUser.h"
#import "FlickrKit.h"
#import "KVNProgress.h"
#import "Lockbox.h"
#import "BFPaperButton.h"
#import "UIColor+FlatUI.h"
#import "NSString+FontAwesome.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *subscribedCartoparties;
@property (nonatomic, retain) BFPaperButton *allRecordsButton;
@property BOOL firstLaunch;
@property BOOL tokenExpired;
@property int cartopartiesCounter;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)showAllRecordsButton {
    self.allRecordsButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-32, self.view.bounds.size.height-82, 65, 65) raised:NO];
    [self.allRecordsButton addTarget:self action:@selector(allRecordsbuttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.allRecordsButton.backgroundColor = [UIColor nephritisColor];
    self.allRecordsButton.tapCircleColor = [UIColor emerlandColor];
    self.allRecordsButton.cornerRadius = self.allRecordsButton.frame.size.width / 2;
    self.allRecordsButton.rippleFromTapLocation = NO;
    self.allRecordsButton.rippleBeyondBounds = YES;
    self.allRecordsButton.tapCircleDiameter = MAX(self.allRecordsButton.frame.size.width, self.allRecordsButton.frame.size.height) * 1.3;
    
    UILabel *allRecordsButtonIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.allRecordsButton.frame.size.width, self.allRecordsButton.frame.size.height)];
    [allRecordsButtonIcon setText:[NSString fontAwesomeIconStringForEnum:FAMapMarker]];
    [allRecordsButtonIcon setTextColor:[UIColor whiteColor]];
    [allRecordsButtonIcon setTextAlignment:NSTextAlignmentCenter];
    [allRecordsButtonIcon setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:38]];
    [self.allRecordsButton addSubview:allRecordsButtonIcon];
    
    [self.navigationController.view addSubview:self.allRecordsButton];
    [self.navigationController.view bringSubviewToFront:self.allRecordsButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenToNotifications];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] invitWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorFromHexCode:@"2AA198"]];
    
//    Custom UIBarButtonItems
    
    UIImage *leftBarButtonItemImage = [UIImage imageNamed:@"icon-exit-app"];
    CGRect leftBarButtonItemFrame = CGRectMake(0, 0, 25, 25);
    
    UIImage *rightBarButtonItemImage = [UIImage imageNamed:@"icon-add-cartoparty"];
    CGRect rightBarButtonItemFrame = CGRectMake(0, 0, 30, 30);
    
    UIButton* leftBarButton = [[UIButton alloc] initWithFrame:leftBarButtonItemFrame];
    [leftBarButton setBackgroundImage:leftBarButtonItemImage forState:UIControlStateNormal];
    
    UIButton* rightBarButton = [[UIButton alloc] initWithFrame:rightBarButtonItemFrame];
    [rightBarButton setBackgroundImage:rightBarButtonItemImage forState:UIControlStateNormal];
    
    [leftBarButton addTarget:self action:@selector(actionLogout:) forControlEvents:UIControlEventTouchDown];
    [rightBarButton addTarget:self action:@selector(showActiveCartoparties:) forControlEvents:UIControlEventTouchDown];

    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.subscribedCartoparties = [NSMutableArray array];
    self.tableData = [NSMutableArray array];
    self.firstLaunch = YES;
    self.tokenExpired = NO;
    self.cartopartiesCounter = -1;
}

- (void)viewDidAppear:(BOOL)animated {
    SJUser *loggedUser = [SJUser sharedManager];

    if ([loggedUser accessToken] == nil && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *dummy = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:dummy animated:NO completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showAllRecordsButton];
    
    SJUser *loggedUser = [SJUser sharedManager];
    
    if ([loggedUser accessToken] != nil && (self.firstLaunch || self.tokenExpired)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        // Download cartoparties I already suscribed to
        self.firstLaunch = NO;
        self.tokenExpired = NO;
        [self getModels];
        if ([self.tableData count] > 0) {
            self.cartopartiesCounter = -1;
            [self.tableData removeAllObjects];
            [self.tableView reloadData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.allRecordsButton removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)listenToNotifications {
    //    Notifications we need to listen to
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getModels)
                                                 name:@"updateFromSubscribedCartopartiesList"
                                               object:nil];
    
}

#pragma mark - API calls

- (void)getModels
{
    // ++++++++++++++++++++++++++++++++++++
    // Get all the model instances on the server
    // ++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
        
        NSString *localizedDescriptionError = [[error userInfo] valueForKey:@"NSLocalizedDescription"];
        
        if ([localizedDescriptionError rangeOfString:@"401"].location != NSNotFound) {
            self.tokenExpired = YES;
            NSLog(@"Token expired!");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *dummy = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:dummy animated:NO completion:nil];
            // Dismiss progress HUD
            [KVNProgress showErrorWithStatus:@"Votre session a expiré\nVeuillez vous identifier à nouveau"];
        }
        else {
            // Dismiss progress HUD
            [KVNProgress showError];
        }

    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
        NSLog( @"selfSuccessBlock %lu", (unsigned long)[models count]);
        
        [self.tableData removeAllObjects];
        
        for (NSDictionary *model in models) {
            
            SJCartoparty *cartoparty = [[SJCartoparty alloc] init];
            
            [cartoparty setFrom:[model valueForKey:@"from"]];
            [cartoparty setTo:[model valueForKey:@"to"]];
            [cartoparty setCities:[model valueForKey:@"cities"]];
            [cartoparty set_description:[model valueForKey:@"description"]];
            [cartoparty setObjectId:[model valueForKey:@"id"]];
            [cartoparty setIsPrivate:[[model valueForKey:@"private"] boolValue]];

            NSDictionary *leaderProperties = [model objectForKey:@"leader"];
            SJCartopartyUser *cartopartyLeader = [[SJCartopartyUser alloc] init];
            
            [cartopartyLeader setUserId:[leaderProperties valueForKey:@"id"]];
            [cartopartyLeader setLastname:[leaderProperties valueForKey:@"lastname"]];
            [cartopartyLeader setFirstname:[leaderProperties valueForKey:@"firstname"]];
            [cartopartyLeader setBirthDate:[leaderProperties valueForKey:@"birthDate"]];
            [cartopartyLeader setUsername:[leaderProperties valueForKey:@"username"]];
            [cartopartyLeader setEmail:[leaderProperties valueForKey:@"email"]];
            [cartopartyLeader setCity:[leaderProperties valueForKey:@"city"]];
            [cartopartyLeader setPicture:[leaderProperties valueForKey:@"picture"]];
            [cartopartyLeader setExpert:[[leaderProperties valueForKey:@"expert"] boolValue]];
            [cartopartyLeader setModerator:[[leaderProperties valueForKey:@"moderator"] boolValue]];
            [cartopartyLeader setElder:[[leaderProperties valueForKey:@"elder"] boolValue]];
            
            [cartoparty setLeader:cartopartyLeader];
            
            [self.tableData addObject:cartoparty];
        }
        
        self.cartopartiesCounter = (int)[self.tableData count];
        [self.tableView reloadData];
        
        [self.subscribedCartoparties setArray:self.tableData];

        for (SJCartoparty *cartoparty in self.tableData) {
        
            //        Flickr API
            FlickrKit *fk = [FlickrKit sharedFlickrKit];
            NSDictionary *cartopartyCity = [[cartoparty cities] firstObject];
            
            [fk call:@"flickr.photos.search" args:@{@"text": [cartopartyCity valueForKey:@"cityname"], @"sort": @"relevance"} completion:^(NSDictionary *response, NSError *error) {
                // Note this is not the main thread!
                if (response) {
//                    NSDictionary *photoData = [[response valueForKeyPath:@"photos.photo"] objectAtIndex:arc4random_uniform(10)];
                    NSDictionary *photoData = [[response valueForKeyPath:@"photos.photo"] objectAtIndex:0];
                    NSURL *url = [fk photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoData];
                    NSLog(@"URL: %@", url);
                    [cartoparty setImageUrl:url];
//                    [self.tableData addObject:cartoparty];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Any GUI related operations here
                        [self.tableView reloadData];
                    });
                }
            }];
            
        }
        
        // Dismiss progress HUD
        [KVNProgress dismiss];
        
        // [self showGuideMessage:@"Great! you just pulled code from node"];
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    LBModelRepository *objectB = [[AppDelegate adapter] repositoryWithModelName:@"users"];
    
    NSString *userId = [[SJUser sharedManager] userId];

    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/users/%@/Cartoparties", userId] verb:@"GET"] forMethod:@"users.cartoparties"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/users/:id/Cartoparties

    [objectB invokeStaticMethod:@"cartoparties" parameters:@{@"filter":@{@"include":@[@"cities", @"leader"]}} success:loadSuccessBlock failure:loadErrorBlock];
    
    // Show a progress HUD
    [KVNProgress show];

};

- (IBAction)actionLogout:(id)sender {
    
    // Define the load success block for the SJUser loginWithEmail message
    void (^loadSuccessBlock)() = ^() {
        
        // Dismiss progress HUD
        [KVNProgress showSuccessWithStatus:@"Déconnecté"];
        self.tokenExpired = YES;
        
        NSLog(@"Successfully logged out");
        
        // Delete our stored token
        [Lockbox setDictionary:nil forKey:@"userCredentials"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *dummy = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:dummy animated:NO completion:nil];
    };//end selfSuccessBlock
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        
        NSLog(@"Error %@", error.description);
        NSLog(@"userInfo error : %@", error.userInfo);
        
        NSString *localizedDescriptionError = [[error userInfo] valueForKey:@"NSLocalizedDescription"];
        
        // Show error HUD - auto dismiss
        [KVNProgress showErrorWithStatus:localizedDescriptionError];
        
    };//end selfFailblock
    
    //Get a local representation of the 'user' model type
    SJUserRepository *userRepository = (SJUserRepository *)[[AppDelegate adapter] repositoryWithClass:[SJUserRepository class]];
    
    // Invoke the logoutWithSuccess message for the 'user' SJUser
    // Equivalent http JSON endpoint request : http://localhost:3000/users/logout
    
    SJUser *loggedUser = [SJUser sharedManager];
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/users/logout?access_token=%@", [loggedUser accessToken]] verb:@"POST"] forMethod:@"users.logout"];
    
//    ?access_token=hSNEufcyDAptx0HsFIA9Z7tW9ao8v7fkYKKRZ8nWdJS32SRC5Nvjy6DMZOecer1r
    
    [userRepository invokeStaticMethod:@"logout" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
//    [userRepository logoutWithSuccess:loadSuccessBlock failure:loadErrorBlock];
    
    // Show a progress HUD
    [KVNProgress show];
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        SJCartoparty *cartoparty = self.tableData[indexPath.row];
        
        CartopartyDetailTableViewController *controller = (CartopartyDetailTableViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailCartoparty:cartoparty];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"showActiveCartoparties"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        LBModel *object = self.tableData[indexPath.row];
        CartopartiesListTableViewController *controller = (CartopartiesListTableViewController *)[segue destinationViewController];
        [controller setSubscribedCartoparties:self.subscribedCartoparties];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - UIButton actions

- (void)allRecordsbuttonWasPressed:(id)sender {
    [self performSegueWithIdentifier:@"showAllRecordsView" sender:self];
}

- (void)showActiveCartoparties:(id)sender {
    [self performSegueWithIdentifier:@"showActiveCartoparties" sender:self];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.cartopartiesCounter == 0)
        return 1;
    else
        return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cartopartiesCounter == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        SJCartoparty *model = (SJCartoparty *)[self.tableData objectAtIndex:indexPath.row];
        
        UIImageView *backgroundImage = (UIImageView*)[cell viewWithTag:10];
        [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [backgroundImage setClipsToBounds:YES];
        [backgroundImage sd_setImageWithURL:[model imageUrl]
                           placeholderImage:[UIImage imageNamed:@"cartoparty-placeholder-master"]];
        
        UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:20];
        descriptionLabel.text = [[NSString alloc] initWithFormat:@"%@",
                                   [model _description] ];
        
        UILabel *dateLabel = (UILabel*)[cell viewWithTag:21];
        dateLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                          [model from], [model to] ];
        
        UIImageView *privateImage = (UIImageView*)[cell viewWithTag:23];
        if ([model isPrivate])
            [privateImage setHidden:NO];
        else
            [privateImage setHidden:YES];
        
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cartopartiesCounter == 0)
        return 250;
    else
        return 160;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

@end
