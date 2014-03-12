//
//  AppDelegate.m
//  Tap That
//
//  Created by Allan Zhang on 2/16/14.
//  Copyright (c) 2014 Allan Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //<---- Global storages ---->
    self.imageStorageDictionary = [[NSMutableDictionary alloc] init];
    self.selectionArray = [[NSMutableArray alloc] init];
    
    [self initializeSelectionArraysIfFirstTime];
    
    //<---- Parse setups ---->
    
    [Parse setApplicationId:@"jizvhaTpVYpH4UNqteweK7Y4cXgpkAWZ6aPUP9Jh"
                  clientKey:@"H2Ru3u733HSRCVWS5DfohHwMAaEAGo83xDDZLrSa"];
    [PFFacebookUtils initializeFacebook];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - starting the database if first time use

- (void)initializeSelectionArraysIfFirstTime
{
    NSUserDefaults *currentUserSelections = [NSUserDefaults standardUserDefaults];
    if (![currentUserSelections objectForKey:@"selections"]){
        
        NSDictionary *set1 = @{@"1" : @"A selfie",
                               @"2" : @"Selfie with a friend",
                               @"3" : @"Selfie with a stranger"};
        
        NSDictionary *set2 = @{@"1" : @"A selfie",
                               @"2" : @"A selfie while at work",
                               @"3" : @"A selfie while in a meeting"};
        
        NSDictionary *set3 = @{@"1" : @"A selfie",
                               @"2" : @"A selfie in your swimsuit",
                               @"3" : @"A selfie (without) your swimsuit"};
        
        [self.selectionArray addObject:set1];
        [self.selectionArray addObject:set2];
        [self.selectionArray addObject:set3];
        
        [currentUserSelections setObject:self.selectionArray forKey:@"selections"];
    }
    
}

@end
