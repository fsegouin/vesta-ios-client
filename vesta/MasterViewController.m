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
#import <SDWebImage/UIImageView+WebCache.h>

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) NSMutableArray *subscribedCartoparties;
@property BOOL firstLaunch;
@property BOOL tokenExpired;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenToNotifications];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.subscribedCartoparties = [NSMutableArray array];
    self.tableData = [NSMutableArray array];
    self.firstLaunch = YES;
    self.tokenExpired = NO;
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
    
    SJUser *loggedUser = [SJUser sharedManager];
    
    if ([loggedUser accessToken] != nil && (self.firstLaunch || self.tokenExpired)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        // Download cartoparties I already suscribed to
        self.firstLaunch = NO;
        self.tokenExpired = NO;
        [self getModels];
    }
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
            [KVNProgress showErrorWithStatus:@"Votre session a expiré.\nVeuillez vous identifier à nouveau."];
        }
        else {
            // Dismiss progress HUD
            [KVNProgress showError];
        }

    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
        NSLog( @"selfSuccessBlock %lu", (unsigned long)[models count]);
//        self.tableData = models;
        
        [self.tableData removeAllObjects];
        
        for (NSDictionary *model in models) {
            
            SJCartoparty *cartoparty = [[SJCartoparty alloc] init];
            
            [cartoparty setFrom:[model valueForKey:@"from"]];
            [cartoparty setTo:[model valueForKey:@"to"]];
            [cartoparty setCities:[model valueForKey:@"cities"]];
            [cartoparty set_description:[model valueForKey:@"description"]];
            [cartoparty setObjectId:[model valueForKey:@"id"]];

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
            
//            [self.subscribedCartoparties addObject:[cartoparty objectId]];
            [self.tableData addObject:cartoparty];

        }
        
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

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    SJCartoparty *model = (SJCartoparty *)[self.tableData objectAtIndex:indexPath.row];
    
    UIImageView *backgroundImage = (UIImageView*)[cell viewWithTag:10];
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [backgroundImage setClipsToBounds:YES];
    [backgroundImage sd_setImageWithURL:[model imageUrl]
                       placeholderImage:nil];
    
    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:20];
    descriptionLabel.text = [[NSString alloc] initWithFormat:@"%@",
                               [model _description] ];
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:21];
    dateLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@",
                      [model from], [model to] ];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
