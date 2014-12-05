//
//  SJUser.h
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <LoopBack/LoopBack.h>

@interface SJUser : LBUser

@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) id accessToken;
@property (strong, nonatomic) NSString *userId;

+ (id)sharedManager;

@end

@interface SJUserRepository : LBUserRepository

+ (instancetype)repository;

@end