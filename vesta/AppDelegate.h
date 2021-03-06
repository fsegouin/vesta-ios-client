//
//  AppDelegate.h
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <LoopBack/LoopBack.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MFMailComposeViewController *globalMailComposer;

+ ( LBRESTAdapter *) adapter;
- (void)cycleTheGlobalMailComposer;

@end

