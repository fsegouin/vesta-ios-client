//
//  DetailViewController.h
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCartoparty.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) SJCartoparty* detailCartoparty;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

