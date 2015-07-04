//
//  GITOrganization.m
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITOrganization.h"

@implementation GITOrganization

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"publicRepos": @"public_repos",
             @"publicGists": @"public_gists",
             @"name": @"name",
             @"createdAt": @"created_at",
             @"url": @"url",
             @"company": @"company",
             @"htmlURL": @"html_url",
             @"email": @"email",
             @"blog": @"blog",
             @"avatarURL": @"avatar_url",
             @"followers": @"followers",
             @"location": @"location",
             @"following": @"following",
             @"login": @"login",
             @"type": @"type",
             @"ID": @"id",
             @"desc": @"description"
             };
}

#pragma mark - API

+ (AFHTTPRequestOperation *)myOrganizationsWithSuccess:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];

    return [client getWithURL:@"/user/orgs" parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITOrganization *org = [GITOrganization objectWithKeyValues:dict];
            [mutableArray addObject:org];
        }
        success([mutableArray copy]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)organizationsOfUser:(NSString *)user
                                        success:(void (^)(NSArray *))success
                                        failure:(GitHubClientFailureBlock)failure;
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/users/%@/orgs", user];
    
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITOrganization *org = [GITOrganization objectWithKeyValues:dict];
            [mutableArray addObject:org];
        }
        success([mutableArray copy]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)infoOfOrganization:(NSString *)orgName
                                       success:(void (^)(GITOrganization *))success
                                       failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/orgs/%@", orgName];
    
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        GITOrganization *org = [GITOrganization objectWithKeyValues:obj];
        success(org);
    } failure:failure];
}

@end
