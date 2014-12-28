//
//  CartopartiesListTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 09/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "SJUser.h"
#import "CartopartiesListTableViewController.h"
#import "AppDelegate.h"
#import "SJCartoparty.h"
#import "FlickrKit.h"
#import "SJCheckButton.h"
#import "SJCartopartyTableViewCell.h"
#import "KVNProgress.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CartopartiesListTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableData;
@property BOOL change;

@end

@implementation CartopartiesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Cartoparties actives";
    self.tableData = [NSMutableArray array];
    
    [self getModels];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.change)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFromSubscribedCartopartiesList" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API calls

- (void)getModels
{
    // +++++++++++++++++++++++++++++++++++++++++
    // Get all the model instances on the server
    // +++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        
        // Dismiss progress HUD
        [KVNProgress showError];
        
        NSLog( @"Error %@", error.description);
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
            
            [self.tableData addObject:cartoparty];
            
        }

    //      We need to set for each cartoparty if currently logged user is already a member.
    //      It should be done server-side, but we had a problem while filtering the data, so
    //      it's done client-side for now (in a really ugly way! /o/)
    
            for (SJCartoparty *subscribedCartoparty in self.subscribedCartoparties) {
                for (SJCartoparty *cartoparty in self.tableData) {
                    if ([[subscribedCartoparty objectId] isEqualToString:[cartoparty objectId]])
                        [cartoparty setIsUserAMember:YES];
                }
            }
        
        for (SJCartoparty *cartoparty in self.tableData) {
            if ([cartoparty imageUrl] == nil) {
                //        Flickr API
                FlickrKit *fk = [FlickrKit sharedFlickrKit];
                NSDictionary *cartopartyCity = [[cartoparty cities] firstObject];
                
                [fk call:@"flickr.photos.search" args:@{@"text": [cartopartyCity valueForKey:@"cityname"], @"sort": @"relevance"} completion:^(NSDictionary *response, NSError *error) {
                    // Note this is not the main thread!
                    if (response) {
                        //                    NSDictionary *photoData = [[response valueForKeyPath:@"photos.photo"] objectAtIndex:arc4random_uniform(10)];
                        NSDictionary *photoData = [[response valueForKeyPath:@"photos.photo"] objectAtIndex:0];
                        NSURL *url = [fk photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoData];
                        //                    NSLog(@"URL: %@", url);
                        [cartoparty setImageUrl:url];
                        //                    [self.tableData addObject:cartoparty];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Any GUI related operations here
                            [self.tableView reloadData];
                        });
                    }
                }];
            }
        }
        
        // Dismiss progress HUD
        [KVNProgress dismiss];
        
        // [self showGuideMessage:@"Great! you just pulled code from node"];
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties?filter
    
    [cartopartyRepository invokeStaticMethod:@"filter" parameters:@{@"filter":@{@"include":@"cities",@"order":@"to ASC"}} success:loadSuccessBlock failure:loadErrorBlock];
    
    // Show a progress HUD
    [KVNProgress show];
    
};

- (void)shouldSubscribe:(BOOL)subscribe ForCartopartyId:(NSString *)cartopartyId  {
    
    // +++++++++++++++++++++++++++++++++++++++++++
    // Post a new link between cartoparty and user
    // PUT /users/{id}/cartoparties/rel/{fk}
    // +++++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSDictionary *) = ^(NSDictionary *model) {
        
        NSLog(@"Response for subscribe (%d): %@", subscribe, model);
        self.change = YES;
        for (SJCartoparty *cartoparty in self.tableData) {
            if ([[cartoparty objectId] isEqualToString:cartopartyId])
                [cartoparty setIsUserAMember:subscribe];
        }
        
//        [self.tableView reloadData];
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    LBModelRepository *objectB = [[AppDelegate adapter] repositoryWithModelName:@"users"];
    
    NSString *userId = [[SJUser sharedManager] userId];
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/users/%@/cartoparties/rel/%@", userId, cartopartyId] verb:@"PUT"] forMethod:@"users.subscribe"];
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/users/%@/cartoparties/rel/%@", userId, cartopartyId] verb:@"DELETE"] forMethod:@"users.unsubscribe"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/users/:id/cartoparties/rel/:fk
    
    if (subscribe)
        [objectB invokeStaticMethod:@"subscribe" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    else
        [objectB invokeStaticMethod:@"unsubscribe" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
}

//#pragma mark - API calls
//
//- (void)getModels
//{
//    // ++++++++++++++++++++++++++++++++++++
//    // Get all the model instances on the server
//    // ++++++++++++++++++++++++++++++++++++
//    
//    // Define the load error functional block
//    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
//        NSLog( @"Error %@", error.description);
//    };//end selfFailblock
//    
//    // Define the load success block for the LBModelRepository allWithSuccess message
//    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
//        NSLog( @"selfSuccessBlock %lu", (unsigned long)[models count]);
//
//        for (NSDictionary *model in models) {
//            SJCartoparty *cartoparty = [[SJCartoparty alloc] init];
//            [cartoparty setFrom:[model valueForKey:@"from"]];
//            [cartoparty setTo:[model valueForKey:@"to"]];
//            [cartoparty setCities:[model valueForKey:@"cities"]];
//            [cartoparty set_description:[model valueForKey:@"description"]];
//            [cartoparty setObjectId:[model valueForKey:@"id"]];
//            [self.tableData addObject:cartoparty];
//        }
//
////
////      We need to set for each cartoparty if currently logged user is already a member.
////      It should be done server-side, but we had a problem while filtering the data, so
////      it's done client-side for now (in a really ugly way! /o/)
////        
//        
//        for (id _id in self.subscribedCartoparties) {
//            for (SJCartoparty *cartoparty in self.tableData) {
//                if ([_id isEqual:[cartoparty objectId]]) {
//                    [cartoparty setIsUserAMember:YES];
//                }
//            }
//        }
//
//        [self.tableView reloadData];
//
//    };//end selfSuccessBlock
//    
//    //Get a local representation of the model type
//    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
//    
//    // Invoke the allWithSuccess message for the LBModelRepository
//    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties?filter
//    
//    [cartopartyRepository invokeStaticMethod:@"filter" parameters:@{@"filter":@{@"include":@"cities",@"order":@"to ASC"}} success:loadSuccessBlock failure:loadErrorBlock];
//    
//    
//};

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableData count];
}


- (SJCartopartyTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    SJCartopartyTableViewCell *cell;
    SJCartoparty *model = (SJCartoparty *)[self.tableData objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.checkButton = (SJCheckButton*)[cell viewWithTag:30];
        [cell.checkButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.checkButton setSelected:[model isUserAMember]];
    }
    
    // Configure the cell...
    
//    SJCartoparty *model = self.tableData[indexPath.row];
//    
//    if ([model isUserAMember]) {
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }
//
////    NSLog(@"Model : %@", model);
//    
//    NSArray *cities = [NSArray arrayWithArray:[model cities]];
//    NSDictionary *cityDictionary = [NSDictionary dictionaryWithDictionary:[cities firstObject]];
//    
//    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",
//                           [model _description] ];
//    
////    NSLog(@"date from : %@", model.from);
//    
//    if ([cityDictionary valueForKey:@"cityname"] != nil) {
//        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",
//                                     [cityDictionary valueForKey:@"cityname"] ];
//    }
//    else
//        cell.detailTextLabel.text = @"N/A";
    
//    SJCartoparty *model = (SJCartoparty *)[self.tableData objectAtIndex:indexPath.row];
    
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
    
//    SJCheckButton *checkButton = (SJCheckButton*)[cell viewWithTag:30];
//    [checkButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    if (cell.checkButton != nil) {
        [cell.checkButton setSelected:[model isUserAMember]];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

#pragma mark - Buttons actions

- (void)checkButtonTapped:(SJCheckButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        NSLog(@"Is button selected? %d", sender.isSelected);
        SJCartoparty *model = (SJCartoparty *)[self.tableData objectAtIndex:indexPath.row];
        [self shouldSubscribe:!sender.isSelected ForCartopartyId:[model objectId]];
        sender.selected = !sender.isSelected;
        
//        if([sender isSelected]) //if the button is selected, deselect it, and then replace the "YES" in the array with "NO"
//        {
//            [self.checkedButtons replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
//            [sender setSelected:NO];
//        }
//        else if (![sender isSelected]) //if the button is unselected, select it, and then replace the "NO" in the array with "YES"
//        {
//            [self.checkedButtons replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
//            [sender setSelected:YES];
//        }
        
//        [self.tableView reloadData];
//        sender.emphasized = !sender.isEmphasized;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
