//
//  SJCartoparty.h
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <LoopBack/LoopBack.h>

@interface SJCartoparty : LBModel

@property (nonatomic, copy) id objectId;
@property (nonatomic, copy) NSString *_description;
@property (nonatomic, copy) NSDate *from;
@property (nonatomic, copy) NSDate *to;
@property (nonatomic, copy) NSArray *cities;
@property (nonatomic, copy) id ownerId;
@property BOOL isUserAMember;

@end

@interface SJCartopartyRepository : LBModelRepository

+ (instancetype)repository;

@end
