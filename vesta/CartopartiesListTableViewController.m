//
//  CartopartiesListTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 09/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "CartopartiesListTableViewController.h"
#import "AppDelegate.h"
#import "SJCartoparty.h"

@interface CartopartiesListTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableData;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
        NSLog( @"selfSuccessBlock %lu", (unsigned long)[models count]);

        for (NSDictionary *model in models) {
            SJCartoparty *cartoparty = [[SJCartoparty alloc] init];
            [cartoparty setFrom:[model valueForKey:@"from"]];
            [cartoparty setTo:[model valueForKey:@"to"]];
            [cartoparty setCities:[model valueForKey:@"cities"]];
            [cartoparty set_description:[model valueForKey:@"description"]];
            [cartoparty setObjectId:[model valueForKey:@"id"]];
            [self.tableData addObject:cartoparty];
        }

//
//      We need to set for each cartoparty if currently logged user is already a member.
//      It should be done server-side, but we had a problem while filtering the data, so
//      it's done client-side for now (in a really ugly way! /o/)
//        
        
        for (id _id in self.subscribedCartoparties) {
            for (SJCartoparty *cartoparty in self.tableData) {
                if ([_id isEqual:[cartoparty objectId]]) {
                    [cartoparty setIsUserAMember:YES];
                }
            }
        }

        [self.tableView reloadData];

    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties?filter
    
    [cartopartyRepository invokeStaticMethod:@"filter" parameters:@{@"filter":@{@"include":@"cities",@"order":@"to ASC"}} success:loadSuccessBlock failure:loadErrorBlock];
    
    
};

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    SJCartoparty *model = self.tableData[indexPath.row];
    
    if ([model isUserAMember]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

//    NSLog(@"Model : %@", model);
    
    NSArray *cities = [NSArray arrayWithArray:[model cities]];
    NSDictionary *cityDictionary = [NSDictionary dictionaryWithDictionary:[cities firstObject]];
    
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",
                           [model _description] ];
    
//    NSLog(@"date from : %@", model.from);
    
    if ([cityDictionary valueForKey:@"cityname"] != nil) {
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",
                                     [cityDictionary valueForKey:@"cityname"] ];
    }
    else
        cell.detailTextLabel.text = @"N/A";
    
    return cell;
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
