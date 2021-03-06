//
//  SJRecord.h
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <LoopBack/LoopBack.h>

@interface SJRecord : LBModel

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSArray *points;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) id userId;
@property (nonatomic, copy) id cartopartyId;

@end

@interface SJRecordRepository : LBModelRepository

+ (instancetype)repository;

@end