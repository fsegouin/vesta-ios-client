//
//  PointListTableViewController.m
//  vesta
//
//  Created by Bastien Jorge on 28/12/2014.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "RecordDetailTableViewController.h"
#import "SJRecord.h"
#import "SJLocation.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define METERS_PER_MILE 1609.344

@interface RecordDetailTableViewController ()

@end

@implementation RecordDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.record name];
    self.mapView.delegate = self;
    
    if([[self.record imageUrl] isKindOfClass:[NSNull class]] || [[self.record imageUrl] isEqualToString:@""])
        [self.recordPicture setImage:[UIImage imageNamed:@"record-nopicture-master"]];
    else
        [self.recordPicture sd_setImageWithURL:[NSURL URLWithString:[self.record imageUrl]] placeholderImage:[UIImage imageNamed:@"record-placeholder-master"]];
    
    self.recordDescription.text = [self.record name];
    self.recordNote.text = [self.record note];
    
    [self parseData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MapKit delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"SJLocation";
    if ([annotation isKindOfClass:[SJLocation class]]) {
        NSString *annotationType = [(SJLocation *)annotation type];
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            if ([annotationType isEqualToString:@"Bâtiment"])
                annotationView.image = [UIImage imageNamed:@"icon-annotation-building"];
            else if ([annotationType isEqualToString:@"Zone"])
                annotationView.image = [UIImage imageNamed:@"icon-annotation-zone"];
            else
                annotationView.image = [UIImage imageNamed:@"icon-annotation-poi"];
            
                                        
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - Class methods

- (void)parseData {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    } // remove old annotations in mapView
    
    for (NSDictionary *point in [self.record points]) {
        NSNumber *latitude = [point valueForKey:@"lat"];
        NSNumber *longitude = [point valueForKey:@"lng"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        SJLocation *annotation = [[SJLocation alloc] initWithName:[self.record name] note:[self.record note] coordinate:coordinate];
        [annotation setType:[[[self.record categories] firstObject] valueForKey:@"name"]];
        [_mapView addAnnotation:annotation];
    }
    
    SJLocation *firstAnnotation = [[self.mapView annotations] firstObject];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([firstAnnotation coordinate], 0.2*METERS_PER_MILE, 0.2*METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [self.tableView reloadData];
}

//#pragma mark - Table view data source


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    //#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    //#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    switch (section) {
//        case 0:
//        case 1:
//            return 1;
//            break;
//        case 2:
//            return ([[self.record points] count] > 0) ? [[self.record points] count] : 1;
//            break;
//        default:
//            break;
//    }
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *cellIdentifier = nil;
//    
//    // Configure the cell...
//    
//    switch (indexPath.section) {
//        case 0:
//            cellIdentifier = @"PictureCell";
//            break;
//        case 1:
//            cellIdentifier = @"MapCell";
//            break;
//        case 2:
//            cellIdentifier = @"GeopointCell";
//            break;
//        default:
//            break;
//    }
//    
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    
//    if (indexPath.section == 0) {
//        UIImageView *recordPicture = (UIImageView *)[cell viewWithTag:10];
//        if([[self.record imageUrl] isKindOfClass:[NSNull class]] || [[self.record imageUrl] isEqualToString:@""])
//            [recordPicture setImage:[UIImage imageNamed:@"record-nopicture-master"]];
//        else
//            [recordPicture sd_setImageWithURL:[NSURL URLWithString:[self.record imageUrl]] placeholderImage:[UIImage imageNamed:@"record-placeholder-master"]];
//        
//        UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:20];
//        descriptionLabel.text = [self.record name];
//        
//        UILabel *noteLabel = (UILabel*)[cell viewWithTag:21];
//        noteLabel.text = [self.record note];
//    }
//    else if (indexPath.section == 1) {
//        MKMapView *mapView = (MKMapView *)[cell viewWithTag:10];
//        mapView.delegate = self;
//        self.mapView = mapView;
//    }
//    else {
//        UILabel *latitudeLabel = (UILabel *)[cell viewWithTag:10];
//        if ([[self.record points] count] > 0) {
////            UILabel *latitudeLabel = (UILabel *)[cell viewWithTag:10];
//            UILabel *longitudeLabel = (UILabel *)[cell viewWithTag:11];
//            NSDictionary *point = [[self.record points] objectAtIndex:indexPath.row];
//            [latitudeLabel setText:[NSString stringWithFormat:@"Latitude : %@", [[point valueForKey:@"lat"] stringValue]]];
//            [longitudeLabel setText:[NSString stringWithFormat:@"Longitude : %@", [[point valueForKey:@"lng"] stringValue]]];
//        }
//        else {
//            [latitudeLabel setText:@"Aucun point enregistré pour ce POI."];
//        }
//    }
//    
//    return cell;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat height = 0;
//    switch (indexPath.section) {
//        case 0:
//            height = 236;
//            break;
//        case 1:
//            height = 150;
//            break;
//        case 2:
//            height = 60;
//            break;
//        default:
//            height = 44;
//            break;
//    }
//    return height;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *headerTitle = nil;
//    
//    switch (section) {
//        case 1:
//            headerTitle = @"Carte";
//            break;
//        case 2:
//            headerTitle = @"Points";
//            
//        default:
//            break;
//    }
//    
//    return headerTitle;
//}

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
