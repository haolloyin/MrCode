//
//  GITRepository.m
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITRepository.h"
#import "NSString+ToNSDate.h"

@implementation GITRepository

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"hasWiki": @"has_wiki",
             @"mirrorURL": @"mirror_url",
             @"forksCount": @"forks_count",
             @"updatedAt": @"updated_at",
             @"isPrivate": @"private",
             @"fullName": @"full_name",
             @"owner": @"owner",
             @"ID": @"id",
             @"size": @"size",
             @"cloneURL": @"clone_url",
             @"watchersCount": @"watchers_count",
             @"stargazersCount": @"stargazers_count",
             @"homepage": @"homepage",
             @"isForked": @"fork",
             @"desc": @"description",
             @"hasDownloads": @"has_downloads",
             @"hasPages": @"has_pages",
             @"defaultBranch": @"default_branch",
             @"htmlURL": @"html_url",
             @"gitURL": @"git_url",
             @"svnURL": @"svn_url",
             @"sshURL": @"ssh_url",
             @"hasIssues": @"has_issues",
             @"permissions": @"permissions",
             @"isAdmin": @"permissions.admin",
             @"canPush": @"permissions.push",
             @"catPull": @"permissions.pull",
             @"openIssuesCount": @"open_issues_count",
             @"name": @"name",
             @"language": @"language",
             @"url": @"url",
             @"createdAt": @"created_at",
             @"pushedAt": @"pushed_at"
             };
}

#pragma mark - Public

+ (BOOL)isStarredRepo:(GITRepository *)repo
{
    NSArray *starredRepos = [GITRepository myStarredRepositories];
    for (GITRepository *item in starredRepos) {
        if ([repo.fullName isEqualToString:item.fullName]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)myStarredRepositories
{
    NSArray *jsonArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_MyStarredRepositories"];
    
    NSMutableArray *repos = [NSMutableArray array];
    for (NSDictionary *item in jsonArray) {
        [repos addObject:[GITRepository objectWithKeyValues:item]];
    }
    NSLog(@"return total starred repos=%@", @(repos.count));
    return [repos copy];
}

+ (void)updateMyStarredRepositories:(NSArray *)repos
{
    if (repos) {
        // 先转化成 Json 字典再持久化
        NSMutableArray *jsonArray = [NSMutableArray array];
        for (GITRepository *item in repos) {
            NSDictionary *jsonDict = item.keyValues;
            [jsonArray addObject:jsonDict];
        }

        [[NSUserDefaults standardUserDefaults] setObject:jsonArray forKey:@"MrCode_MyStarredRepositories"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"update total starred repos=%@", @(repos.count));
    }
}

#pragma mark - Private

- (NSString *)repositoryTypeToString:(JGHRepositoryType)type
{
    NSArray *repositoryType = @[@"all", @"owner", @"public", @"private", @"member", @"forks", @"sources"];
    return repositoryType[type];
}

+ (AFHTTPRequestOperation *)repositoriesOfUrl:(NSString *)url success:(void (^)(NSArray *))success failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITRepository *repos = [GITRepository objectWithKeyValues:dict];
            [mutableArray addObject:repos];
        }
        success([mutableArray copy]);
    } failure:failure];
}

#pragma mark - API

+ (AFHTTPRequestOperation *)myRepositoriesWithSuccess:(void (^)(NSArray *))success
                                              failure:(GitHubClientFailureBlock)failure
{
    return [GITRepository repositoriesOfUrl:@"/user/repos?sort=created" success:success failure:failure];
}

+ (AFHTTPRequestOperation *)repositoriesOfUser:(NSString *)user
                                          type:(JGHRepositoryType)type
                                        sortBy:(JGHRepositorySortBy)sortBy
                                       orderBy:(JGHRepositoryOrderBy)orderBy
                                       success:(void (^)(NSArray *))success
                                       failure:(GitHubClientFailureBlock)failure
{
    // TODO
    return [GITRepository repositoriesOfUser:user success:success failure:failure];
}

+ (AFHTTPRequestOperation *)repositoriesOfUser:(NSString *)user
                                       success:(void (^)(NSArray *))success
                                       failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/users/%@/repos", user];
    return [GITRepository repositoriesOfUrl:url success:success failure:failure];
}

+ (AFHTTPRequestOperation *)repositoriesOfOrganization:(NSString *)org
                                               success:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/orgs/%@/repos", org];
    return [GITRepository repositoriesOfUrl:url success:success failure:failure];
}

+ (AFHTTPRequestOperation *)publicRepositoriesSince:(NSString *)since
                                            success:(void (^)(NSArray *))success
                                            failure:(GitHubClientFailureBlock)failure;
{
    NSString *url = [NSString stringWithFormat:@"/repositories?since=%@", since ? since : @"0"];
    return [GITRepository repositoriesOfUrl:url success:success failure:failure];
}

+ (AFHTTPRequestOperation *)starredRepositoriesByUser:(NSString *)user
                                              success:(void (^)(NSArray *))success
                                              failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/users/%@/starred?sort=created", user];
    return [GITRepository repositoriesOfUrl:url
                                    success:^(NSArray *repos) {
                                        [GITRepository updateMyStarredRepositories:repos]; // 保存
                                        success(repos);
                                    }failure:failure];
}

+ (AFHTTPRequestOperation *)starRepository:(GITRepository *)repo
                                   success:(void (^)(BOOL))success
                                   failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/user/starred/%@/%@", repo.owner.login, repo.name];
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client putWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        // See https://developer.github.com/v3/activity/starring/#response-2
        if (operation.response.statusCode == 204) {
            
            // 保存新增的 star
            NSArray *starredRepos = [GITRepository myStarredRepositories];
            NSMutableArray *newStarredRepos = [NSMutableArray arrayWithArray:starredRepos];
            [newStarredRepos addObject:repo];
            [GITRepository updateMyStarredRepositories:newStarredRepos];
            
            success(YES);
        }
    } failure:failure];
}

+ (AFHTTPRequestOperation *)unstarRepository:(GITRepository *)repo
                                     success:(void (^)(BOOL))success
                                     failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/user/starred/%@/%@", repo.owner.login, repo.name];
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client deleteWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        // See https://developer.github.com/v3/activity/starring/#response-2
        if (operation.response.statusCode == 204) {
            
            NSArray *starredRepos = [GITRepository myStarredRepositories];
            NSMutableArray *newStarredRepos = [NSMutableArray array];
            
            for (GITRepository *item in starredRepos) {
                if (![item.fullName isEqualToString:repo.fullName]) {
                    [newStarredRepos addObject:item];
                }
            }
            [GITRepository updateMyStarredRepositories:newStarredRepos];
            
            success(YES);
        }
    } failure:failure];
}

+ (AFHTTPRequestOperation *)watchRepository:(GITRepository *)repo
                                    success:(void (^)(BOOL))success
                                    failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/user/subscriptions/%@/%@", repo.owner.login, repo.name];
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client putWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        // See https://developer.github.com/v3/activity/watching/#response-4
        if (operation.response.statusCode == 204) {
            success(YES);
        }
    } failure:failure];
}

+ (AFHTTPRequestOperation *)unwatchRepository:(GITRepository *)repo
                                      success:(void (^)(BOOL))success
                                      failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/user/subscriptions/%@/%@", repo.owner.login, repo.name];
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client deleteWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        // See https://developer.github.com/v3/activity/watching/#response-5
        if (operation.response.statusCode == 204) {
            success(YES);
        }
    } failure:failure];
}

@end
