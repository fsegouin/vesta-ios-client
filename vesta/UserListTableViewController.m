//
//  UserListTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "UserListTableViewController.h"
#import "SJCartopartyUser.h"
#import "SJCartoparty.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BMInitialsPlaceholderView.h"
#import "UIColor+FlatUI.h"
#import "SJMedalView.h"
#import "NSString+FontAwesome.h"

@interface UserListTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableData;

@end

@implementation UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Participants";
    
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
            
            SJCartopartyUser *user = [[SJCartopartyUser alloc] init];
            
            [user setUserId:[model valueForKey:@"id"]];
            [user setLastname:[model valueForKey:@"lastname"]];
            [user setFirstname:[model valueForKey:@"firstname"]];
            [user setBirthDate:[model valueForKey:@"birthDate"]];
            [user setUsername:[model valueForKey:@"username"]];
            [user setEmail:[model valueForKey:@"email"]];
            [user setCity:[model valueForKey:@"city"]];
            [user setPicture:[model valueForKey:@"picture"]];
            [user setExpert:[[model valueForKey:@"expert"] boolValue]];
            [user setModerator:[[model valueForKey:@"moderator"] boolValue]];
            [user setElder:[[model valueForKey:@"elder"] boolValue]];
            
            [self.tableData addObject:user];
            
        }
        
        [self.tableView reloadData];
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    SJCartopartyRepository *cartopartyRepository = (SJCartopartyRepository *)[[AppDelegate adapter] repositoryWithClass:[SJCartopartyRepository class]];
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Cartoparties/%@/users", self.cartopartyId] verb:@"GET"] forMethod:@"Cartoparties.users"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Cartoparties/:id/users
    
    [cartopartyRepository invokeStaticMethod:@"users" parameters:nil success:loadSuccessBlock failure:loadErrorBlock];
    
};

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2)
        [cell setBackgroundColor:[UIColor colorFromHexCode:@"f7f7f7"]];
    else
        [cell setBackgroundColor:[UIColor whiteColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SJCartopartyUser *user = [self.tableData objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    SJMedalView *medalView = (SJMedalView *)[cell viewWithTag:10];
    if ([user expert])
        [medalView setExpert:YES];
    else if ([user moderator])
        [medalView setModerator:YES];
    else if ([user elder])
        [medalView setElder:YES];
    
    UIImageView *profilePicture = (UIImageView*)[cell viewWithTag:11];
    [profilePicture sd_setImageWithURL:[NSURL URLWithString:[user picture]] placeholderImage:nil];
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
    profilePicture.clipsToBounds = YES;
    
    UILabel *medalIconLabel = (UILabel*)[cell viewWithTag:12];
    medalIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:10];
    medalIconLabel.textColor = [UIColor whiteColor];
    if ([user expert])
        medalIconLabel.text = [NSString fontAwesomeIconStringForEnum:FARocket];
    else if ([user moderator])
        medalIconLabel.text = [NSString fontAwesomeIconStringForEnum:FAThumbsUp];
    else if ([user elder])
        medalIconLabel.text = [NSString fontAwesomeIconStringForEnum:FAStar];
    
    UILabel *fullnameLabel = (UILabel*)[cell viewWithTag:20];
    fullnameLabel.text = [NSString stringWithFormat:@"%@ %@", [user firstname], [user lastname]];
    
    UILabel *cityLabel = (UILabel*)[cell viewWithTag:21];
    cityLabel.text = [user city];
    
    UILabel *cityIconLabel = (UILabel*)[cell viewWithTag:22];
    cityIconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:10];
    cityIconLabel.textColor = [UIColor colorFromHexCode:@"d7d1cd"];
    cityIconLabel.text = [NSString fontAwesomeIconStringForEnum:FAMapMarker];
    
    UIButton *contactButton = (UIButton *)[cell viewWithTag:30];
    [contactButton addTarget:self action:@selector(showEmail:) forControlEvents:UIControlEventTouchUpInside];
    contactButton.clipsToBounds = YES;
    contactButton.layer.cornerRadius = 15;
    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [user firstname], [user lastname]];
//    cell.detailTextLabel.text = [user username];
    

    
//    BMInitialsPlaceholderView *placeholder = [[BMInitialsPlaceholderView alloc] initWithDiameter:40.0f];
//    
//    [placeholder batchUpdateViewWithInitials:[self initialStringForPersonString:[NSString stringWithFormat:@"%@ %@", [user firstname], [user lastname]]]
//                                 circleColor:[self randomCircleColor]
//                                   textColor:[UIColor whiteColor]
//                                        font:[UIFont fontWithName:@"Monserrat-Regulat" size:18.0]];
    
//    cell.accessoryView = profilePicture;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 63;
}

#pragma mark - Email

- (IBAction)showEmail:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SJCartopartyUser *selectedUser = [self.tableData objectAtIndex:indexPath.row];
    
    if ( [MFMailComposeViewController canSendMail] )
    {
        
        // Email Subject
        NSString *emailTitle = [NSString stringWithFormat:@"Contact pour une cartopartie"] ;
        [APP.globalMailComposer setSubject:emailTitle];
        //    // Email Content
        NSString *messageBody = @"iOS programming is so fun!";
        [APP.globalMailComposer setMessageBody:messageBody isHTML:NO];

        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:[selectedUser email]];
        [APP.globalMailComposer setToRecipients:toRecipents];
        
//        [APP.globalMailComposer setToRecipients:
//         [NSArray arrayWithObjects: emailAddressNSString, nil] ];
//        [APP.globalMailComposer setSubject:subject];
//        [APP.globalMailComposer setMessageBody:msg isHTML:NO];
        APP.globalMailComposer.mailComposeDelegate = self;
        [self presentViewController:APP.globalMailComposer
                           animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Unable to mail. No email on this device?");
        [APP cycleTheGlobalMailComposer];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:^
     { [APP cycleTheGlobalMailComposer]; }
     ];
}

//- (UIColor *)randomCircleColor {
//    return [UIColor colorWithHue:arc4random() % 256 / 256.0 saturation:0.7 brightness:0.8 alpha:1.0];
//}
//
//- (NSString *)initialStringForPersonString:(NSString *)personString {
//    NSArray *comps = [personString componentsSeparatedByString:@" "];
//    if ([comps count] >= 2) {
//        NSString *firstName = comps[0];
//        NSString *lastName = comps[1];
//        return [NSString stringWithFormat:@"%@%@", [firstName substringToIndex:1], [lastName substringToIndex:1]];
//    } else if ([comps count]) {
//        NSString *name = comps[0];
//        return [name substringToIndex:1];
//    }
//    return @"?";
//}

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
