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
             @"isSiteAdmin": @"site_admin",
             @"subscriptionsURL": @"subscriptions_url",
             @"gravatarId": @"gravatar_id",
             @"isHireable": @"hireable",
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

+ (void)storeCurrentAuthenticatedUser:(NSDictionary *)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
    for (NSString *key in dict.allKeys) {
        // FIXME: 这里搞这么复杂是因为当 value 为 NSNull 时 NSUserDefaults 保存会报错
        if ([dict[key] isKindOfClass:[NSNull class]]) {
            dict[key] = nil;
        }
    }
    
    // 保存整个授权对象，以及用户名
    [[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:kAUTHENTICATED_USER];
    [[NSUserDefaults standardUserDefaults] setObject:obj[@"login"] forKey:kAUTHENTICATED_USER_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (GITUser *)getCurrentAuthenticatedUser
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kAUTHENTICATED_USER];
    if (obj) {
        return [GITUser objectWithKeyValues:obj];
    }
    return nil;
}

#pragma mark - API

+ (NSString *)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAUTHENTICATED_USER_IDENTIFIER];
}

+ (AFHTTPRequestOperation *)authenticatedUserWithSuccess:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    GITUser *currentUser = [GITUser getCurrentAuthenticatedUser];
    if (currentUser) {
        success(currentUser);
        return nil;
    }
    else {
        return [client getWithURL:@"/user" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *obj) {
            [self storeCurrentAuthenticatedUser:obj];
            GITUser *user = [GITUser objectWithKeyValues:obj];
            success(user);
        } failure:failure];
    }
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

+ (AFHTTPRequestOperation *)followersOfUser:(NSString *)user
                                    success:(void (^)(NSArray *))success
                                    failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/users/%@/followers", user];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITUser *item = [GITUser objectWithKeyValues:dict];
            [mutableArray addObject:item];
        }
        success([mutableArray copy]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)followingOfUser:(NSString *)user
                                    success:(void (^)(NSArray *))success
                                    failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/users/%@/following", user];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITUser *item = [GITUser objectWithKeyValues:dict];
            [mutableArray addObject:item];
        }
        success([mutableArray copy]);
    } failure:failure];
}

@end
