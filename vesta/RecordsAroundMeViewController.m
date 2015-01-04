//
//  RecordsAroundMeViewController.m
//  vesta
//
//  Created by Florent Segouin on 02/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "SJLocation.h"
#import "RecordsAroundMeViewController.h"

#define METERS_PER_MILE 1609.344
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface RecordsAroundMeViewController ()

@property (strong, nonatomic) MKUserLocation* currentLocation;
@property (strong, nonatomic) NSMutableArray* points;
@property BOOL dataAlreadyDownloaded;

@end

@implementation RecordsAroundMeViewController

//    REIMS LOCATION - DEBUG
//    49.2535423, 4.0318015

//    UTT LOCATION - DEBUG
//    48.26902, 4.06725

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Autour de moi";
    
    self.points = [NSMutableArray array];
    
    // Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    self.locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [self.locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [self.locationManager setDistanceFilter:10.0f]; // Only updated each 50 meters
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    self.currentLocation = userLocation;
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2*METERS_PER_MILE, 2*METERS_PER_MILE);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
////    if (self.dataAlreadyDownloaded == FALSE)
//    [self getModels];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    MKUserLocation *lastLocation = [locations lastObject];
    
    if (self.currentLocation == nil) { // first launch
        self.currentLocation = lastLocation;
        [self updateMapRegionWithLocation:lastLocation];
    }
    
    else { // for each update
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:lastLocation.coordinate.latitude longitude:lastLocation.coordinate.longitude];
        CLLocationDistance distance = [startLocation distanceFromLocation:endLocation]; // aka double
        NSLog(@"Distance since last location : %f", distance);
        
        if (distance > 10.0f) { // need to update region
            self.currentLocation = lastLocation;
            [self updateMapRegionWithLocation:lastLocation];
        } // else, do nothing
        
    }
    
}

- (void)updateMapRegionWithLocation:(MKUserLocation *)location {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, METERS_PER_MILE, METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    [self getModels];
}

#pragma mark - API calls

- (void)getModels
{
    // ++++++++++++++++++++++++++++++++++++
    // Get all the model instances on the server
    // ++++++++++++++++++++++++++++++++++++
    
    // Define the load error functional block
    void (^loadErrorBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error %@", error.description);
    };//end selfFailblock
    
    // Define the load success block for the LBModelRepository allWithSuccess message
    void (^loadSuccessBlock)(NSDictionary *) = ^(NSDictionary *models) {
        NSLog(@"selfSuccessBlock %lu", (unsigned long)[models count]);
        self.dataAlreadyDownloaded = TRUE;
        
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            [_mapView removeAnnotation:annotation];
        } // remove old annotations in mapView
        
        for (NSDictionary *record in [models objectForKey:@"records"]) {
            NSString *name = [record valueForKey:@"name"];
            NSString *note = [record valueForKey:@"note"];
            
            NSArray *points = [record objectForKey:@"points"];
            NSDictionary *firstPoint = [points firstObject];
            NSNumber *latitude = [firstPoint valueForKey:@"lat"];
            NSNumber *longitude = [firstPoint valueForKey:@"lng"];
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = latitude.doubleValue;
            coordinate.longitude = longitude.doubleValue;
            SJLocation *annotation = [[SJLocation alloc] initWithName:name note:note coordinate:coordinate];
            [_mapView addAnnotation:annotation];
        } // add our new annotations to mapView
        
    };//end selfSuccessBlock
    
    //Get a local representation of the model type
    LBModelRepository *objectB = [[AppDelegate adapter] repositoryWithModelName:@"Records"];
    
    // Invoke the allWithSuccess message for the LBModelRepository
    // Equivalent http JSON endpoint request : http://localhost:3000/api/Records/inZone/:lat1/:lng1/:lat2/:lng2
    
    [[[AppDelegate adapter] contract] addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/Records/inZone/%@", [self getRegionFromCurrentLocationWithRadius:10]] verb:@"GET"] forMethod:@"Records.inZone"];
    
    [objectB invokeStaticMethod:@"inZone" parameters:@{@"limit":@"30"} success:loadSuccessBlock failure:loadErrorBlock];
    
};


- (NSString *)getRegionFromCurrentLocationWithRadius:(double)radius {
    
    double R = 6371;  // Earth radius in km
    
    double x1 = self.currentLocation.coordinate.longitude - RADIANS_TO_DEGREES(radius/R/cosf(DEGREES_TO_RADIANS(self.currentLocation.coordinate.latitude)));
    
    double x2 = self.currentLocation.coordinate.longitude + RADIANS_TO_DEGREES(radius/R/cosf(DEGREES_TO_RADIANS(self.currentLocation.coordinate.latitude)));
    
    double y1 = self.currentLocation.coordinate.latitude + RADIANS_TO_DEGREES(radius/R);
    
    double y2 = self.currentLocation.coordinate.latitude - RADIANS_TO_DEGREES(radius/R);
    
    return [NSString stringWithFormat:@"%f/%f/%f/%f/",y2,x1,y1,x2];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
