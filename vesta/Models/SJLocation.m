//
//  SJLocation.m
//  vesta
//
//  Created by Florent Segouin on 02/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import "SJLocation.h"

@interface SJLocation ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation SJLocation

- (id)initWithName:(NSString*)name note:(NSString *)note coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]])
            self.name = name;
        else
            self.name = @"Unknown name";
        self.note = note;
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _note;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
