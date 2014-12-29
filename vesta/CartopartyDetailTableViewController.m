//
//  CartopartyDetailTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 11/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CartopartyDetailTableViewController.h"
#import "RecordListTableViewController.h"
#import "UserListTableViewController.h"
#import "SJUser.h"
#import "SJCheckButton.h"
#import "SJCartoparty.h"
#import "THProgressView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+FontAwesome.h"
#import "UIColor+FlatUI.h"
#import "SphereMenu.h"

@interface CartopartyDetailTableViewController () <SphereMenuDelegate>

//@property (nonatomic, retain) SphereMenu* sphereMenu;

@end

@implementation CartopartyDetailTableViewController

#pragma mark - Managing the detail item

- (void)setDetailCartoparty:(SJCartoparty *)newDetailCartoparty {
    if (_detailCartoparty != newDetailCartoparty) {
        _detailCartoparty = newDetailCartoparty;
        
        // Update the view.
//        [self configureView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    SJUser *loggedUser = [SJUser sharedManager];
//    if ([loggedUser accessToken] != nil && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
    UIImage *startImage = [UIImage imageNamed:@"start"];
    UIImage *image1 = [UIImage imageNamed:@"icon-map-marker"];
    UIImage *image2 = [UIImage imageNamed:@"icon-building"];
    UIImage *image3 = [UIImage imageNamed:@"icon-compass"];
    UIImage *image4 = [UIImage imageNamed:@"icon-pencil"];
    NSArray *images = @[image1, image2, image3, image4];
    SphereMenu *sphereMenu = [[SphereMenu alloc] initWithStartPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-120)
                                                         startImage:startImage
                                                      submenuImages:images];
    sphereMenu.delegate = self;
    [self.view addSubview:sphereMenu];
    
    [self.cartopartyImage sd_setImageWithURL:[self.detailCartoparty imageUrl] placeholderImage:nil];
    
    [self.leaderImage sd_setImageWithURL:[NSURL URLWithString:[[self.detailCartoparty leader] picture]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    self.leaderImage.layer.cornerRadius = self.leaderImage.frame.size.width / 2;
    self.leaderImage.layer.borderWidth = 2.0f;
    self.leaderImage.layer.borderColor = [UIColor colorFromHexCode:@"ecf0f1"].CGColor;
    
    self.medalIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:10];
    if ([[self.detailCartoparty leader] expert]) {
        self.medalIcon.text = [NSString fontAwesomeIconStringForEnum:FARocket];
        [self.medalView setExpert:YES];
    }
    else if ([[self.detailCartoparty leader] moderator]) {
        self.medalIcon.text = [NSString fontAwesomeIconStringForEnum:FAThumbsUp];
        [self.medalView setModerator:YES];
    }
    else if ([[self.detailCartoparty leader] elder]) {
        self.medalIcon.text = [NSString fontAwesomeIconStringForEnum:FAStar];
        [self.medalView setElder:YES];
    }
    else
        self.medalIcon.text = @"";

    self.cartopartyDescriptionLabel.text = [[NSString alloc] initWithFormat:@"%@", [self.detailCartoparty _description]];
    self.cartopartyDateLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.detailCartoparty from], [self.detailCartoparty to] ];
    
    self.subscribersIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:32];
    self.pointsIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:36];
    self.meetupsIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:36];

    self.subscribersIconLabel.text = [NSString fontAwesomeIconStringForEnum:FAUsers];
    self.pointsIconLabel.text = [NSString fontAwesomeIconStringForEnum:FAMapMarker];
    self.meetupsIconLabel.text = [NSString fontAwesomeIconStringForEnum:FACalendar];
    
    [self.progressView setProgress:0.5f animated:YES];
        
    [self getUsersCount];
    [self getRecordsCount];
    
//    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - API calls

- (void)getRecordsCount
{
    // ++++++++++++++++++++++++++++++++++++++++++++++++++
    // Get records count for this cartoparty on the server
    // GET /Cartoparties/{id}/users/count
    // ++++++++++++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSDictionary *) = ^(NSDictionary *model) {
        self.pointsNumberLabel.text = [NSString stringWithFormat:@"%@", [model valueForKey:@"count"]];
        [[self tableView] reloadData];

    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties/:id/records/count
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Cartoparties/%@/records/count", [_detailCartoparty objectId]] verb:@"GET"] forMethod:@"Cartoparties.countRecords"];
    
    [cartopartyRepository invokeStaticMethod:@"countRecords" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
};

- (void)getUsersCount
{
    // +++++++++++++++++++++++++++++++++++++++++++++++++
    // Get users count for this cartoparty on the server
    // GET /Cartoparties/{id}/users/count
    // +++++++++++++++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog( @"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSDictionary *) = ^(NSDictionary *model) {
        self.subscribersNumberLabel.text = [NSString stringWithFormat:@"%@", [model valueForKey:@"count"]];
        [[self tableView] reloadData];
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties/:id/users/count
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Cartoparties/%@/users/count", [_detailCartoparty objectId]] verb:@"GET"] forMethod:@"Cartoparties.countUsers"];
    
    [cartopartyRepository invokeStaticMethod:@"countUsers" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
};


//#pragma mark - Buttons actions
//
//- (IBAction)subscribeButtonAction:(SJCheckButton *)sender {
//    sender.selected = !sender.isSelected;
//}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return 38;
    else
        return 0;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]];
//    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.contentView setBackgroundColor:[UIColor colorFromHexCode:@"F1F1F1"]];
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

#pragma mark - SphereMenu delegate methods


- (void)sphereDidSelected:(int)index
{
    NSLog(@"sphere %d selected", index);
    
    switch (index) {
        case 0:
            [self performSegueWithIdentifier:@"showAddRecordView" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"showAddRecordView" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showAddRecordView" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"showEditRecordView" sender:self];
            break;
        default:
            break;
    }
}


#pragma mark - Navigation

//- (IBAction)test:(id)sender {
//    [self performSegueWithIdentifier:@"showEditRecordView" sender:sender];
//}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showRecordList"]) {
        RecordListTableViewController *controller = (RecordListTableViewController *)[segue destinationViewController];
        [controller setCartopartyId:[self.detailCartoparty objectId]];
    }
    else if ([[segue identifier] isEqualToString:@"showUserList"]) {
        UserListTableViewController *controller = (UserListTableViewController *)[segue destinationViewController];
        [controller setCartopartyId:[self.detailCartoparty objectId]];
    }
}

@end
