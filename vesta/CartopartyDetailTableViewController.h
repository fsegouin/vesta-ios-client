//
//  CartopartyDetailTableViewController.h
//  vesta
//
//  Created by Florent Segouin on 11/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCartoparty.h"

@interface CartopartyDetailTableViewController : UITableViewController

@property (strong, nonatomic) SJCartoparty* detailCartoparty;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cartopartyImage;
@property (weak, nonatomic) IBOutlet UILabel *cartopartyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cartopartyDateLabel;

@end
