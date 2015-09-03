//
//  GITRepository.m
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITRepository.h"
#import "NSString+ToNSDate.h"
#import "KVStoreManager.h"

static NSString *MyStarredRepositories = @"MrCode_MyStarredRepositories";
static NSString *MyOwnedRepositories = @"MrCode_MyOwnedRepositories";
static NSString *kReposReadMeTableName = @"MrCode_ReposReadMeTableName";

//static NSString *kHTMLTemplateString = @"<html><head><meta charset='utf-8'>"
//"<link crossorigin=\"anonymous\" href=\"https://assets-cdn.github.com/assets/github-11f9d64531e606e5dcae92cd4bc5db0397294f98aca5575628fe6cba053ebeef.css\" media=\"all\" rel=\"stylesheet\"/>"
//"<link crossorigin=\"anonymous\" href=\"https://assets-cdn.github.com/assets/github2-c0d3df1e6943fef2afbe89f45c3ee9bfbedf1deaf2ec3b76e55192a78f137218.css\" media=\"all\" rel=\"stylesheet\"/>"
//"<title>%@</title></head><body>%@</body></html>";
static NSString *kHTMLTemplateString = @"<html><head><meta charset='utf-8'>"
"<link crossorigin=\"anonymous\" href=\"github1.css\" media=\"all\" rel=\"stylesheet\"/>"
"<link crossorigin=\"anonymous\" href=\"github2.css\" media=\"all\" rel=\"stylesheet\"/>"
"<title>%@</title></head><body>%@</body></html>";

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
    NSArray *jsonArray = [[NSUserDefaults standardUserDefaults] objectForKey:MyStarredRepositories];
    
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

        [[NSUserDefaults standardUserDefaults] setObject:jsonArray forKey:MyStarredRepositories];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"update total starred repos=%@", @(repos.count));
    }
}

+ (NSArray *)myOwnedRepositories
{
    NSArray *jsonArray = [[NSUserDefaults standardUserDefaults] objectForKey:MyOwnedRepositories];
    
    NSMutableArray *repos = [NSMutableArray array];
    for (NSDictionary *item in jsonArray) {
        [repos addObject:[GITRepository objectWithKeyValues:item]];
    }
    NSLog(@"return total owned repos=%@", @(repos.count));
    return [repos copy];
}

+ (void)updateMyOwnedRepositories:(NSArray *)repos
{
    if (repos) {
        // 先转化成 Json 字典再持久化
        NSMutableArray *jsonArray = [NSMutableArray array];
        for (GITRepository *item in repos) {
            NSDictionary *jsonDict = item.keyValues;
            [jsonArray addObject:jsonDict];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:jsonArray forKey:MyOwnedRepositories];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"update total owned repos=%@", @(repos.count));
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
    return [GITRepository repositoriesOfUrl:@"/user/repos?sort=created" success:^(NSArray *repos) {
        // 每次调用 API 成功获取之后都保存到本地
        [GITRepository updateMyOwnedRepositories:repos];
        success(repos);
    } failure:failure];
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
    return [GITRepository repositoriesOfUrl:url success:^(NSArray *repos) {
        
        if ([user isEqualToString:[GITUser username]]) {
            [GITRepository updateMyStarredRepositories:repos]; // 保存
        }
        success(repos);
    } failure:failure];
}

//+ (AFHTTPRequestOperation *)forksOfRepository:(GITRepository *)repo
//                                      success:(void (^)(NSArray *))success
//                                      failure:(GitHubClientFailureBlock)failure
//{
//    NSString *url = [NSString stringWithFormat:@"/repos/%@/%@/forks?sort=newest", repo.owner.login, repo.name];
//    return [GITRepository repositoriesOfUrl:url success:success failure:failure];
//}

+ (AFHTTPRequestOperation *)forksOfRepository:(GITRepository *)repoName
                                      success:(void (^)(NSArray *))success
                                      failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/repos/%@/forks?sort=newest", repoName];
    return [GITRepository repositoriesOfUrl:url success:success failure:failure];
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

- (AFHTTPRequestOperation *)readmeWithsuccess:(void (^)(NSString *))success
                                      failure:(GitHubClientFailureBlock)failure
                                  needRefresh:(BOOL)refresh
{
    if (refresh) {
        return [self readmeWithsuccess:success failure:failure];
    }
    
    NSString *key = [self readmeStoreKey];
    NSString *readmeHTMLString = [[KVStoreManager sharedStore] getStringById:key fromTable:kReposReadMeTableName];
    if (!readmeHTMLString) {
        NSLog(@"no cache");
        return [self readmeWithsuccess:success failure:failure];
    }
    NSLog(@"cached");
    success(readmeHTMLString);

    return nil;
}

- (NSString *)readmeStoreKey
{
    return [NSString stringWithFormat:@"%@_README_KEY", self.fullName];
}

- (AFHTTPRequestOperation *)readmeWithsuccess:(void (^)(NSString *))success
                                      failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    // 苍天啊，原来 AF 直接不接受这种 Accept，直接在 error 的代码里根据 StatusCode==200 判断算了
    // 参考这里并各种设置测试都无效：http://stackoverflow.com/questions/19114623
    [client setValue:@"application/vnd.github.VERSION.html" forHeader:@"Accept"];
//    [client setAcceptableContentTypes:@"application/vnd.github.VERSION.html"];
    
    NSString *url = [NSString stringWithFormat:@"/repos/%@/readme", self.fullName];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *dict) {
        
        NSString *base64String = dict[@"content"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *content = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSString *html = [NSString stringWithFormat:kHTMLTemplateString, self.fullName, content];
        [self storeReadmeHTML:html];
        NSLog(@"refresh README ok");
        success(html);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 200) {
            NSData *encodedData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            NSString *content = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
            NSString *html = [NSString stringWithFormat:kHTMLTemplateString, self.fullName, content];
            [self storeReadmeHTML:html];
            NSLog(@"refresh README error but ok");
            success(html);
        }
        else {
            failure(operation, error);
        }
    }];
}

- (void)storeReadmeHTML:(NSString *)html
{
    [[KVStoreManager sharedStore] createTableWithName:kReposReadMeTableName];
    [[KVStoreManager sharedStore] putString:html withId:[self readmeStoreKey] intoTable:kReposReadMeTableName];
}

@end
