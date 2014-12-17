//
//  SJRecord.m
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "SJRecord.h"

@implementation SJRecord

@end

@implementation SJRecordRepository

+ (instancetype)repository {
    SJRecordRepository *repository = [self repositoryWithClassName:@"Records"];
    repository.modelClass = [SJRecord class];
    return repository;
}

@end
