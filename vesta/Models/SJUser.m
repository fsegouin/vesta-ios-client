//
//  SJUser.m
//  vesta
//
//  Created by Florent Segouin on 05/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "SJUser.h"

@implementation SJUser

#pragma mark Singleton Methods

+ (id)sharedManager {
    static SJUser *sharedSJUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSJUser = [[self alloc] init];
    });
    return sharedSJUser;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
    }
    return self;
}

@end

@implementation SJUserRepository

+ (instancetype)repository {
    return [self repositoryWithClassName:@"users"];
}

- (void)storeAccessTokenInAdapter:(NSString *)accessToken {
    LBRESTAdapter* adapter = (LBRESTAdapter*)self.adapter;
    adapter.accessToken = accessToken;
}

@end