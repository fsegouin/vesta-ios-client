//
//  SJCartoparty.m
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "SJCartoparty.h"

@implementation SJCartoparty

- (NSString *)getStringFromJsonDate:(NSString *)jsonDate {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDate *date = [dateFormat dateFromString:jsonDate];
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc]init];
    [newDateFormatter setDateFormat:@"dd MMM yyy"];
    NSString *newString = [newDateFormatter stringFromDate:date];
    
    return newString;
    
}

- (void)setFrom:(NSString *)newFrom {
    
    _from = [self getStringFromJsonDate:newFrom];
    
}

- (void)setTo:(NSString *)newTo {
    
    _to = [self getStringFromJsonDate:newTo];
    
}

@end

@implementation SJCartopartyRepository

+ (instancetype)repository {
    SJCartopartyRepository *repository = [self repositoryWithClassName:@"Cartoparties"];
    repository.modelClass = [SJCartoparty class];
    return repository;
}

@end