//
//  SJCryptorWrapper.h
//  vesta
//
//  Created by Florent Segouin on 04/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCryptorWrapper : NSObject

+ (BOOL)decryptCredentials;
+ (BOOL)encryptCredentialsWithAccessToken:(NSString *)accessToken AndUserId:(NSString *)userId;
+ (void)clearKeychainData;

@end
