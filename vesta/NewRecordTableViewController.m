//
//  NewRecordTableViewController.m
//  vesta
//
//  Created by Florent Segouin on 03/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import "NewRecordTableViewController.h"
#import "AppDelegate.h"
#import "SJCartoparty.h"
#import "SJUser.h"
#import "AFNetworking.h"
#import "KVNProgress.h"
#import "UIImage+Resizing.h"
#import "NSString+FontAwesome.h"
#import "UIColor+FlatUI.h"

#define METERS_PER_MILE 1609.344

@interface NewRecordTableViewController () <FDTakeDelegate, UITextFieldDelegate>

@property (strong, nonatomic) MKUserLocation* currentLocation;
@property (strong, nonatomic) UIImage* recordPicture;

@end

@implementation NewRecordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;

    [self.recordTitleTextField setDelegate:self];
//    [self.recordNotesTextView setDelegate:self];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    
    NSLog(@"Record type to add: %ld", self.recordType);
        
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelView:)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"Ajouter"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(addItem:)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.rightBarButtonItem = addItem;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    self.recordNotesTextView.font = [UIFont systemFontOfSize:16.0];
    self.recordTypeLabel.text = [self recordTypeStringFromEnum];
    
    self.validPictureLabel.text = [NSString fontAwesomeIconStringForEnum:FACheckCircleO];
    self.validPictureLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    self.validPictureLabel.textColor = [UIColor emerlandColor];
    self.validPictureLabel.textAlignment = NSTextAlignmentCenter;
    
    // Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    self.locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [self.locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [self.locationManager setDistanceFilter:5.0f];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)recordTypeStringFromEnum {
    static NSString *recordTypeString;
    
    switch (self.recordType) {
        case 0:
            recordTypeString = @"Point d'intérêt";
            break;
        case 1:
            recordTypeString = @"Bâtiment";
            break;
        case 2:
            recordTypeString = @"Zone";
            break;
        default:
            break;
    }
    
    return recordTypeString;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.currentLocation = userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 0.1*METERS_PER_MILE, 0.1*METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    NSLog(@"Current user location : lat: %f - lng: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    if (![self.navigationItem.leftBarButtonItem isEnabled])
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

#pragma mark - API methods

- (void)addNewRecordToApiWithPicture:(NSString *)picture {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializerRequest = [AFJSONRequestSerializer serializer];
    [serializerRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = serializerRequest;

    NSString *urlString = [NSString stringWithFormat:@"http://vesta-api.herokuapp.com/api/Cartoparties/%@/records?access_token=%@", self.cartopartyId, [[SJUser sharedManager] accessToken]];
    
    [manager POST:urlString
       parameters:@{
                    @"name": self.recordTitleTextField.text,
                    @"note": self.recordNotesTextView.text,
                    @"picture": picture,
                    @"userId": [[SJUser sharedManager] userId],
                    @"points": @[@{
                                     @"lat": [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude],
                                     @"lng": [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude]
                                }]
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Record added to cartoparty!");
              [KVNProgress showSuccessWithStatus:@"Enregistrement ajouté"];
              [self cancelView:nil];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Failure %@, %@", error, operation.responseString);
              [KVNProgress showErrorWithStatus:@"Impossible de contacter le serveur"];
          }];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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



//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

- (void)addNewRecord {
    if (self.recordTitleTextField.text.length < 2) {
        [KVNProgress showErrorWithStatus:@"Le titre de l'enregistrement doit contenir au moins 3 lettres"];
    }
    else if (self.recordNotesTextView.text.length == 0) {
        [KVNProgress showErrorWithStatus:@"Une note de l'utilisateur sur l'enregistrement est obligatoire"];
    }
    else {
        [KVNProgress show];
        if (self.recordPicture != nil) { // Check if the user took a picture
            NSString *fileName = @"picture_.jpg";
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer             = [AFJSONResponseSerializer serializer];
            
            //        PROD URL
            NSString *urlString = @"http://188.166.54.59:3000/api/photo/";
            
            UIImage *scaledImage  = [self.recordPicture scaleToFitSize:CGSizeMake(720, 480)];
            NSData *imageData     = UIImageJPEGRepresentation(scaledImage, 1.0);
            
            [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success - URL : %@", [responseObject valueForKey:@"file"]);
                [self addNewRecordToApiWithPicture:[NSString stringWithFormat:@"http://188.166.54.59:3000%@", [responseObject valueForKey:@"file"]]];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failure %@, %@", error, operation.responseString);
                [KVNProgress showErrorWithStatus:@"Impossible de contacter le serveur"];
            }];
        }
        else {
            [self addNewRecordToApiWithPicture:@""];
        }
    }
}

#pragma mark - Navigation bar items

- (void)cancelView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addItem:(id)sender {
    [self addNewRecord];
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    self.recordPicture = photo;
    [self.validPictureLabel setHidden:NO];
}

- (IBAction)takePhotoOrChooseFromLibrary:(id)sender {
    [self.takeController takePhotoOrChooseFromLibrary];
}

@end
