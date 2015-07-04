//
//  AppDelegate.m
//  MrCode
//
//  Created by hao on 7/3/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "AppDelegate.h"
#import "GitHubOAuthClient.h"

NSString * const kClientID         = @"a17a1237e6cb4e8ac584";
NSString * const kClientSecret     = @"9df3af59331d5618d66a0c2f95a1e833e4c388bb";
NSString * const kRedirectURL      = @"MrCode://OAuth";
NSString * const kOAuthScope       = @"user,public_repo,repo,notifications,gist,read:org";

NSString * const kGitHubAPIBaseURL = @"https://api.github.com";
NSString * const kAuthorizeURL     = @"https://github.com/login/oauth/authorize";
NSString * const kAccessURL        = @"https://github.com/login/oauth/access_token";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupGitHubOAuth];
    
    return YES;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"\nsourceApplication Bundle ID: %@\nURL: %@\nannotation: %@", sourceApplication, url, annotation);
    
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    if ([[[url absoluteString] lowercaseString] hasPrefix:[client redirectURLString]]) {
        [client handleRedirectURL:url];
        return  YES;
    }
    
    return NO;
}

#pragma mark - Private

- (void)setupGitHubOAuth
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    if (!client.alreadyOAuth) {
        [client setupWithClientID:kClientID
                           secret:kClientSecret
                          baseURL:kGitHubAPIBaseURL
                     authorizeURL:kAuthorizeURL
                      redirectURL:kRedirectURL
                   accessTokenURL:kAccessURL];
        
        [client authorizeWithScope:kOAuthScope];
    }
}

@end
