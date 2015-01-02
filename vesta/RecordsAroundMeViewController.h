//
//  RecordsAroundMeViewController.h
//  vesta
//
//  Created by Florent Segouin on 02/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RecordsAroundMeViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
