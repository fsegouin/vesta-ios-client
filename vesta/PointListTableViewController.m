//
//  PointListTableViewController.m
//  vesta
//
//  Created by Bastien Jorge on 28/12/2014.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "PointListTableViewController.h"
#import "SJRecord.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PointListTableViewController ()

@property (strong, nonatomic) SJRecord *record;
@property (strong, nonatomic) NSMutableArray *tableData;


@end

@implementation PointListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.recordName;
    self.record = [[SJRecord alloc] init];
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
    // Get the model instances on the server
    // +++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSDictionary *) = ^(NSDictionary *model) {
        
        [self.record setName:[model valueForKey:@"name"]];
        [self.record setNote:[model valueForKey:@"note"]];
        [self.record setUserId:[model valueForKey:@"userId"]];
        [self.record setCartopartyId:[model valueForKey:@"cartopartyId"]];
        [self.record setObjectId:[model valueForKey:@"id"]];
        [self.record setPoints:[model objectForKey:@"points"]];
        
        [self.tableView reloadData];
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJRecordRepository *recordRepository = (SJRecordRepository *)[[AppDelegate adapter] repositoryWithClass:[SJRecordRepository class]];
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Records/%@", self.recordId] verb:@"GET"] forMethod:@"Records.findById"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Records/:id
    
    [recordRepository invokeStaticMethod:@"findById" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
};

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return ([[self.record points] count] > 0) ? [[self.record points] count] : 1;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = nil;
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0)
                cellIdentifier = @"PictureCell";
            else if (indexPath.row == 1)
                cellIdentifier = @"NoteCell";
            break;
        case 1:
            cellIdentifier = @"GeopointCell";
            break;
        default:
            break;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIImageView *recordPicture = (UIImageView *)[cell viewWithTag:10];
            //            serverIcon.alpha = 0.5;
            //            [serverIcon setImage:[UIImage imageNamed:@"camera-icon"]];
            
            
            //            NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:@"http://www.toilettes-mps.com/photos/_MPS-Toilettes-Publiques_11_20131006_171229.jpg"]];
            
            //            [recordPicture setImage:[UIImage imageWithData: data]];
            
            
            [recordPicture sd_setImageWithURL:[NSURL URLWithString:@"http://www.toilettes-mps.com/photos/_MPS-Toilettes-Publiques_11_20131006_171229.jpg"] placeholderImage:nil];
        }
        else if (indexPath.row == 1) {
            //            UILabel *label = (UILabel *)[cell viewWithTag:20];
            cell.textLabel.text = ([self.record note] == nil) ? @"Pas de description." : [self.record note];
            [cell.textLabel setTextColor:[UIColor grayColor]];
            
            
        }
    }
    else {
        if ([[self.record points] count] > 0) {
            NSDictionary *point = [[self.record points] objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"lat : %@, long : %@", [point valueForKey:@"lat"], [point valueForKey:@"lng"]];
        }
        else
            cell.textLabel.text = @"Aucun point enregistré pour ce POI.";
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0)
                height = 236;
            else if (indexPath.row == 1)
                height = 44;
            break;
        case 1:
            height = 44;
            break;
        default:
            height = 44;
            break;
    }
    return height;
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
