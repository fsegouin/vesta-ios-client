//
//  CartopartyDetailTableViewController.h
//  vesta
//
//  Created by Florent Segouin on 11/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCartoparty.h"
#import "THProgressView.h"
#import "SJMedalView.h"

@interface CartopartyDetailTableViewController : UITableViewController

@property (strong, nonatomic) SJCartoparty* detailCartoparty;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cartopartyImage;
@property (weak, nonatomic) IBOutlet UILabel *cartopartyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cartopartyDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscribersIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetupsIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscribersNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetupsNumberLabel;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *leaderImage;
@property (weak, nonatomic) IBOutlet SJMedalView *medalView;
@property (weak, nonatomic) IBOutlet UILabel *medalIcon;
@property (weak, nonatomic) IBOutlet UIImageView *privateIcon;

@end
