//
//  SJCryptorWrapper.m
//  vesta
//
//  Created by Florent Segouin on 04/01/15.
//  Copyright (c) 2015 utt. All rights reserved.
//

#import "SJCryptorWrapper.h"
#import "AppDelegate.h"
#import "SJUser.h"
#import "Lockbox.h"
#import "FCUUID.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"

@implementation SJCryptorWrapper

+ (BOOL)decryptCredentials {
    // Check for credentials in Keychain, decrypt them and store them in RESTAdapter
    
    BOOL returnValue = FALSE;
    // Check for existing user access token
    SJUser *loggedUser = [SJUser sharedManager];
    
    NSDictionary *credentials = [Lockbox dictionaryForKey:@"userCredentials"];
    if (credentials != nil) {
        
        // Get our unique FCUUID
        NSString *uuidForDevice = [FCUUID uuidForDevice];
        
        NSError *error = nil;
        
        NSData *encryptedUserIdFromBase64String = [[NSData alloc] initWithBase64EncodedString:[credentials valueForKey:@"userId"] options:0];
        NSData *encryptedAccessTokenFromBase64String = [[NSData alloc] initWithBase64EncodedString:[credentials valueForKey:@"accessToken"] options:0];
        
        NSData *decryptedUserId = [RNDecryptor decryptData:encryptedUserIdFromBase64String
                                              withPassword:uuidForDevice
                                                     error:&error];
        
        NSString *userId = [[NSString alloc] initWithData:decryptedUserId encoding:NSUTF8StringEncoding];
        
        NSData *decryptedAccessToken = [RNDecryptor decryptData:encryptedAccessTokenFromBase64String
                                                   withPassword:uuidForDevice
                                                          error:&error];
        NSString *accessToken = [[NSString alloc] initWithData:decryptedAccessToken encoding:NSUTF8StringEncoding];
        
        NSLog(@"Credentials found in keychain!");
        [loggedUser setUserId:userId];
        [loggedUser setAccessToken:accessToken];
        SJUserRepository *userRepository = (SJUserRepository *)[[AppDelegate adapter] repositoryWithClass:[SJUserRepository class]];
        [userRepository storeAccessTokenInAdapter:accessToken];
        returnValue = TRUE;
    }
    else {
        NSLog(@"No credentials in keychain..");
        returnValue = FALSE;
    }
    return returnValue;
}

+ (BOOL)encryptCredentialsWithAccessToken:(NSString *)accessToken AndUserId:(NSString *)userId {
    // Encrypt credentials and store them in keychain
    
    // Get our unique FCUUID
    NSString *uuidForDevice = [FCUUID uuidForDevice];
    
    NSData *userIdData = [userId dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedUserId = [RNEncryptor encryptData:userIdData
                                          withSettings:kRNCryptorAES256Settings
                                              password:uuidForDevice
                                                 error:&error];
    
    NSData *accessTokenData = [accessToken dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedAccessToken = [RNEncryptor encryptData:accessTokenData
                                               withSettings:kRNCryptorAES256Settings
                                                   password:uuidForDevice
                                                      error:&error];
    
    NSString *encryptedUserIdBase64String = [encryptedUserId base64EncodedStringWithOptions:0];
    NSString *encryptedAccessTokenBase64String = [encryptedAccessToken base64EncodedStringWithOptions:0];

    BOOL successfullySetToKeychain = [Lockbox setDictionary:@{@"accessToken":encryptedAccessTokenBase64String,@"userId":encryptedUserIdBase64String} forKey:@"userCredentials"];
    if (successfullySetToKeychain) {
        NSLog(@"Access token successfully set to Keychain!");
    }
    else {
        NSLog(@"Error while setting token to Keychain");
    }
    
    return successfullySetToKeychain;
}

+ (void)clearKeychainData {
    [Lockbox setDictionary:nil forKey:@"userCredentials"];
}

@end
