//
//  GITUser.m
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITUser.h"

@implementation GITUser

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"publicRepos": @"public_repos",
             @"siteAdmin": @"site_admin",
             @"subscriptionsURL": @"subscriptions_url",
             @"gravatarId": @"gravatar_id",
             @"hireable": @"hireable",
             @"ID": @"id",
             @"followersURL": @"followers_url",
             @"followingURL": @"following_url",
             @"blog": @"blog",
             @"followers": @"followers",
             @"location": @"location",
             @"type": @"type",
             @"email": @"email",
             @"bio": @"bio",
             @"gistsURL": @"gists_url",
             @"company": @"company",
             @"eventsURL": @"events_url",
             @"htmlURL": @"html_url",
             @"updatedAt": @"updated_at",
             @"receivedEventsURL": @"received_events_url",
             @"starredURL": @"starred_url",
             @"publicGists": @"public_gists",
             @"name": @"name",
             @"organizationsURL": @"organizations_url",
             @"url": @"url",
             @"createdAt": @"created_at",
             @"avatarURL": @"avatar_url",
             @"reposURL": @"repos_url",
             @"following": @"following",
             @"login": @"login"
             };
}

#pragma mark - private

+ (void)storeCurrentAuthenticatedUser:(GITUser *)user
{
    [[NSUserDefaults standardUserDefaults] setObject:user.login forKey:kAUTHENTICATED_USER_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - API

+ (NSString *)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAUTHENTICATED_USER_IDENTIFIER];
}

+ (AFHTTPRequestOperation *)authenticatedUserWithSuccess:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    return [client getWithURL:@"/user" parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        GITUser *user = [GITUser objectWithKeyValues:obj];
        [self storeCurrentAuthenticatedUser:user];
        success(user);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)userWithUserName:(NSString *)username success:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/users/%@", username];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        GITUser *user = [GITUser objectWithKeyValues:obj];
        success(user);
    } failure:failure];
}

@end
