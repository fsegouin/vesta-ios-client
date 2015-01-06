//
//  PointListTableViewController.h
//  vesta
//
//  Created by Bastien on 28/12/2014.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SJRecord.h"

@interface RecordDetailTableViewController : UITableViewController <MKMapViewDelegate>

//@property (strong, nonatomic) NSString *recordId;
//@property (strong, nonatomic) NSString *recordName;
@property (strong, nonatomic) SJRecord *record;
//@property (retain, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *recordPicture;
@property (weak, nonatomic) IBOutlet UILabel *recordDescription;
@property (weak, nonatomic) IBOutlet UILabel *recordNote;

@end
