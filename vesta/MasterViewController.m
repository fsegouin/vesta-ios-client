//
//  MasterViewController.m
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "CartopartiesListTableViewController.h"
#import "SJUser.h"
#import "SJCartoparty.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSMutableArray *subscribedCartoparties;
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
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.subscribedCartoparties = [NSMutableArray array];
    
}

- (void)viewDidAppear:(BOOL)animated {
    SJUser *loggedUser = [SJUser sharedManager];
    if ([loggedUser accessToken] == nil && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *dummy = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:dummy animated:NO completion:nil];
//        call cartoparty download method
//        [self getModels];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    SJUser *loggedUser = [SJUser sharedManager];

    if ([loggedUser accessToken] != nil) {
        //        Download cartoparties I already suscribed to
        [self getModels];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

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
        self.tableData = models;
        
        for (NSDictionary *cartoparty in models) {
            [self.subscribedCartoparties addObject:[cartoparty valueForKey:@"id"]];
            NSLog(@"Cartoparty id : %@", [cartoparty valueForKey:@"id"]);
        }
        
        [self.tableView reloadData];
        // [self showGuideMessage:@"Great! you just pulled code from node"];
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    LBModelRepository *objectB = [[AppDelegate adapter] repositoryWithModelName:@"users"];
    
    NSString *userId = [[SJUser sharedManager] userId];

    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/users/%@/Cartoparties", userId] verb:@"GET"] forMethod:@"users.cartoparties"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/products
    
//    [objectB allWithSuccess: loadSuccessBlock failure: loadErrorBlock];
//    NSString *token = [[SJUser sharedManager] accessToken];

    [objectB invokeStaticMethod:@"cartoparties" parameters:@{@"filter":@{@"include":@"cities"}} success:loadSuccessBlock failure:loadErrorBlock];

};

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        LBModel *object = self.tableData[indexPath.row];
        NSDictionary *objectSelected = self.tableData[indexPath.row];
        
        SJCartoparty *cartoparty = [[SJCartoparty alloc] init];
        [cartoparty setFrom:[objectSelected valueForKey:@"from"]];
        [cartoparty setTo:[objectSelected valueForKey:@"to"]];
        [cartoparty setCities:[objectSelected valueForKey:@"cities"]];
        [cartoparty set_description:[objectSelected valueForKey:@"description"]];
        [cartoparty setObjectId:[objectSelected valueForKey:@"id"]];

        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
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

    LBModel *model = (LBModel *)[self.tableData objectAtIndex:indexPath.row];
    
    NSArray *cities = [NSArray arrayWithArray:[model objectForKeyedSubscript:@"cities"]];
    NSDictionary *cityDictionary = [NSDictionary dictionaryWithDictionary:[cities firstObject]];
    
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",
                               [model objectForKeyedSubscript:@"description"] ];
    
    if ([cityDictionary valueForKey:@"cityname"] != nil) {
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",
                                     [cityDictionary valueForKey:@"cityname"] ];
    }
    else
        cell.detailTextLabel.text = @"N/A";

    return cell;
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
