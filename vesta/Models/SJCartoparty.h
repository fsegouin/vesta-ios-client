//
//  SJCartoparty.h
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <LoopBack/LoopBack.h>
#import "SJCartopartyUser.h"

@interface SJCartoparty : LBModel

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *_description;
@property (nonatomic, copy) NSURL *imageUrl;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, copy) NSString *fullDate;
@property (nonatomic, copy) NSArray *cities;
@property (nonatomic, retain) SJCartopartyUser *leader;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, assign) BOOL isUserAMember;
@property (nonatomic, assign) BOOL isPrivate;

@end

@interface SJCartopartyRepository : LBModelRepository

+ (instancetype)repository;

@end
