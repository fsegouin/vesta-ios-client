//
//  CartopartyDetailTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 11/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "LoginViewController.h"
#import "CartopartyDetailTableViewController.h"
#import "SJUser.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CartopartyDetailTableViewController ()

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
    
    [self.cartopartyImage sd_setImageWithURL:[_detailCartoparty imageUrl] placeholderImage:nil];
    self.cartopartyDescriptionLabel.text = [[NSString alloc] initWithFormat:@"%@", [_detailCartoparty _description]];
    self.cartopartyDateLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", [_detailCartoparty from], [_detailCartoparty to] ];

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

#pragma mark - Table view data source

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
