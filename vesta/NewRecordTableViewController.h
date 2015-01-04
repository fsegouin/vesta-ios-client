//
//  NewRecordTableViewController.h
//  vesta
//
//  Created by Florent Segouin on 03/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SZTextView.h"
#import "FDTakeController.h"

@interface NewRecordTableViewController : UITableViewController <MKMapViewDelegate, CLLocationManagerDelegate>
    
typedef NS_ENUM(NSInteger, RecordType) {
    kPOI,
    kBuilding,
    kZone
};

@property (weak, nonatomic) IBOutlet UITextField *recordTitleTextField;
@property (weak, nonatomic) IBOutlet SZTextView *recordNotesTextView;
@property (weak, nonatomic) IBOutlet UILabel *recordTypeLabel;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *validPictureLabel;

@property (weak, nonatomic) NSString *cartopartyId;
@property RecordType recordType;
@property FDTakeController *takeController;

- (IBAction)takePhotoOrChooseFromLibrary:(id)sender;

@end
