//
//  SJLocation.h
//  vesta
//
//  Created by Florent Segouin on 02/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SJLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name note:(NSString*)note coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
