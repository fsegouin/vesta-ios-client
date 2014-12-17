//
//  SJCartopartyUser.h
//  vesta
//
//  Created by Florent Segouin on 16/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <LoopBack/LoopBack.h>

@interface SJCartopartyUser : LBModel

@property (strong, nonatomic) id userId;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *birthDate;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *picture;
@property (nonatomic, assign) BOOL moderator;
@property (nonatomic, assign) BOOL expert;
@property (nonatomic, assign) BOOL elder;

@end
