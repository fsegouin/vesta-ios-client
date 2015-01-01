//
//  RecordListTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "RecordListTableViewController.h"
#import "RecordDetailTableViewController.h"
#import "SJCartoparty.h"
#import "SJRecord.h"

@interface RecordListTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableData;

@end

@implementation RecordListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Points enregistrés";
    
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
    // +++++++++++++++++++++++++++++++++++++++++
    // Get all the model instances on the server
    // +++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSArray *) = ^(NSArray *models) {
        NSLog( @"selfSuccessBlock %lu", (unsigned long)[models count]);
        
        for (NSDictionary *model in models) {
            
            SJRecord *record = [[SJRecord alloc] init];
            
            [record setName:[model valueForKey:@"name"]];
            [record setNote:[model valueForKey:@"note"]];
            [record setUserId:[model valueForKey:@"userId"]];
            [record setCartopartyId:[model valueForKey:@"cartopartyId"]];
            [record setObjectId:[model valueForKey:@"id"]];
            [record setPoints:[model objectForKey:@"points"]];
            
            [self.tableData addObject:record];
            
        }
        
        [self.tableView reloadData];
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Cartoparties/%@/records", self.cartopartyId] verb:@"GET"] forMethod:@"Cartoparties.records"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties/:id/records
    
    [cartopartyRepository invokeStaticMethod:@"records" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
};


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    SJRecord *record = [self.tableData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [record name];
    [cell.textLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14]];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showRecordDetailList"])
    {
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        RecordDetailTableViewController *controller = [segue destinationViewController];
        SJRecord *selectedRecord = [self.tableData objectAtIndex:selectedIndex];
        [controller setRecordId: [NSString stringWithFormat:@"%@", [selectedRecord objectId]]];
        [controller setRecordName: [selectedRecord name]];
        
        
    }
}


@end
