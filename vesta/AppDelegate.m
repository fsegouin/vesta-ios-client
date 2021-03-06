//
//  AppDelegate.m
//  vesta
//
//  Created by Florent Segouin on 03/12/14.
//  Copyright (c) 2014 utt. All rights reserved.
//

#import "AppDelegate.h"
#import "CartopartyDetailTableViewController.h"
#import "FlickrKit.h"
#import "SJUser.h"
#import "SJCryptorWrapper.h"
#import "UIColor+FlatUI.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

static LBRESTAdapter * _adapter = nil;

+ (LBRESTAdapter *) adapter
{
    if ( !_adapter) {
        
//        API root path
//        
//        DEBUG -- LOCAL
//        _adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000/api/"]];
        
//        
//        PROD -- HEROKU
        _adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@API_ROOT]];
        
//        Add custom routes (static methods)
        [[_adapter contract] addItem:[SLRESTContractItem itemWithPattern:@"/Cartoparties" verb:@"GET"] forMethod:@"Cartoparties.filter"];
        
    }
    return _adapter;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
        
    // Uncomment this line if you already have data for vesta in your keychain and need to reset it
    // Then kill the app, comment this line again and rebuild the app
//    [SJCryptorWrapper clearKeychainData];
    
    // Flickr API Wraper
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    [fk initializeWithAPIKey:@FLICKR_API_KEY sharedSecret:@FLICKR_SHARED_SECRET];
    
    // Check for credentials in Keychain, decrypt them and store them in RESTAdapter
    [SJCryptorWrapper decryptCredentials];
    
    // We need to initialize our MailComposerViewController and hold it into one static variable (thank you Apple)
    [self cycleTheGlobalMailComposer];
    
    return YES;
}

-(void)cycleTheGlobalMailComposer
{
    // we are cycling the damned GlobalMailComposer... due to horrible iOS issue
    self.globalMailComposer = nil;
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[CartopartyDetailTableViewController class]] && ([(CartopartyDetailTableViewController *)[(UINavigationController *)secondaryViewController topViewController] detailCartoparty] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
