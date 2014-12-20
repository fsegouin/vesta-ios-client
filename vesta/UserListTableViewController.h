//
//  UserListTableViewController.h
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface UserListTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSString *cartopartyId;

@end
