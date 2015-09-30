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
#import "MrCodeConst.h"

static NSString *RepositoriesTableName = @"MrCode_RepositoriesTableName";
static NSString *MyStarredRepositories = @"MrCode_MyStarredRepositories";
static NSString *MyOwnedRepositories = @"MrCode_MyOwnedRepositories";
static NSString *kReposReadMeTableName = @"MrCode_ReposReadMeTableName"; // 保存多个 repos 的 README 内容
static NSString *kReposFileContentTableName = @"MrCode_ReposFileContentTableName"; // 保存多个 repos 的多个目录
static NSString *kReposContentsTableName = @"MrCode_ReposContentsTableName"; // 保存多个 repos 的多个文件内容

@implementation GITRepositoryContent

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"name": @"name",
             @"path": @"path",
             @"sha": @"sha",
             @"size": @"size",
             @"url": @"url",
             @"htmlURL": @"html_url",
             @"gitURL": @"git_url",
             @"downloadURL": @"download_url",
             @"size": @"type",
             @"linksSelfURL": @"_links.self",
             @"linksGitURL": @"_links.git",
             @"linksHtmlURL": @"_links.html"
             };
}

- (NSString *)apiPath
{
    NSString *sitePrefix = [NSString stringWithFormat:@"https://api.github.com/repos/%@/contents/", self.repoFullName];
    NSString *path = [self.url.absoluteString stringByReplacingOccurrencesOfString:sitePrefix withString:@""];
    NSLog(@"url=%@,\nsitePrefix=%@,\npath=%@", self.url.absoluteString, sitePrefix, path);
    return path;
}

#pragma mark - Public

- (AFHTTPRequestOperation *)fileOfPath:(NSString *)path
                           needRefresh:(BOOL)needRefresh
                               success:(void (^)(NSString *))success
                               failure:(GitHubClientFailureBlock)failure
{
    NSString *html;
    if (!needRefresh) {
        NSString *key = [NSString stringWithFormat:@"%@/%@", self.repoFullName, self.apiPath];
        html = [[KVStoreManager sharedStore] getStringById:key fromTable:kReposFileContentTableName];
    }
    
    if (html) {
        NSLog(@"hit cache");
        success(html);
        return nil;
    }
    
    NSLog(@"no hit cache or need refresh");
    
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    [client setValue:@"application/vnd.github.VERSION.html" forHeader:@"Accept"];
    
    NSString *url = [NSString stringWithFormat:@"/repos/%@/contents/%@", self.repoFullName, path];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *dict) {
        
        NSString *base64String = dict[@"content"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *content = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSString *html = [NSString stringWithFormat:MCGitHubHTMLTemplateString, self.repoFullName, content];

        NSLog(@"ok");
        [self storeFileContent:html withKey:[NSString stringWithFormat:@"%@/%@", self.repoFullName, path]];
        
        success(html);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 200) {
            NSData *encodedData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            NSString *content = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
            NSString *html = [NSString stringWithFormat:MCGitHubHTMLTemplateString, self.repoFullName, content];
            
            NSLog(@"error but ok");
            [self storeFileContent:html withKey:[NSString stringWithFormat:@"%@/%@", self.repoFullName, path]];
            success(html);
        }
        else {
            failure(operation, error);
        }
    }];
}

#pragma makr - Private

- (void)storeFileContent:(NSString *)content withKey:(NSString *)key
{
    [[KVStoreManager sharedStore] createTableWithName:kReposFileContentTableName];
    [[KVStoreManager sharedStore] putString:content withId:key intoTable:kReposFileContentTableName];
}

@end


@interface GITRepository ()

@end


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
    NSArray *cachedRepos = [[KVStoreManager sharedStore] getObjectById:MyStarredRepositories fromTable:RepositoriesTableName];
    NSArray *starredRepos = [GITRepository jsonArrayToModelArray:cachedRepos];
    
    for (GITRepository *item in starredRepos) {
        if ([repo.fullName isEqualToString:item.fullName]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - API

+ (AFHTTPRequestOperation *)repositoriesOfUser:(NSString *)user
                                   needRefresh:(BOOL)needRefresh
                                    parameters:(NSDictionary *)parameters
                                       success:(void (^)(NSArray *))success
                                       failure:(GitHubClientFailureBlock)failure
{
    // 本人
    if ([user isEqualToString:[GITUser username]] && !parameters) {
        return [GITRepository myRepositoriesNeedRefresh:needRefresh parameters:parameters success:success failure:failure];
    }
    
    NSString *url = [NSString stringWithFormat:@"/users/%@/repos", user];
    return [GITRepository repositoriesOfUrl:url parameters:parameters success:^(NSArray *repos) {
        success([GITRepository jsonArrayToModelArray:repos]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)starredRepositoriesByUser:(NSString *)user
                                          needRefresh:(BOOL)needRefresh
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(NSArray *))success
                                              failure:(GitHubClientFailureBlock)failure
{
    // 本人
    if ([user isEqualToString:[GITUser username]]) {
        return [GITRepository myStarredRepositoriesNeedRefresh:needRefresh parameters:parameters success:success failure:failure];
    }
    
    NSString *url = [NSString stringWithFormat:@"/users/%@/starred?sort=created", user];
    return [GITRepository repositoriesOfUrl:url parameters:parameters success:^(NSArray *repos) {
        success([GITRepository jsonArrayToModelArray:repos]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)forksOfRepository:(GITRepository *)repoName
                                   parameters:(NSDictionary *)parameters
                                      success:(void (^)(NSArray *))success
                                      failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/repos/%@/forks?sort=newest", repoName];
    return [GITRepository repositoriesOfUrl:url parameters:parameters success:^(NSArray *repos) {
        success([GITRepository jsonArrayToModelArray:repos]);
    } failure:failure];
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
            NSArray *starredRepos = [GITRepository getCachedObjectByKey:MyStarredRepositories];
            NSMutableArray *newStarredRepos = [NSMutableArray arrayWithArray:starredRepos];
            [newStarredRepos addObject:repo];
            [GITRepository storeObject:[newStarredRepos copy] byKey:MyStarredRepositories pagination:NO];
            
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
            
            NSArray *starredRepos = [GITRepository getCachedObjectByKey:MyStarredRepositories];
            NSMutableArray *newStarredRepos = [NSMutableArray array];
            
            for (GITRepository *item in starredRepos) {
                if (![item.fullName isEqualToString:repo.fullName]) {
                    [newStarredRepos addObject:item];
                }
            }
            [GITRepository storeObject:[newStarredRepos copy] byKey:MyStarredRepositories pagination:NO];
            
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

- (AFHTTPRequestOperation *)contentsOfPath:(NSString *)path
                               needRefresh:(BOOL)needRefresh
                                   success:(void (^)(NSArray *))success
                                   failure:(GitHubClientFailureBlock)failure
{
    NSMutableArray *array = [NSMutableArray array];
    path = path ?: @"";
    NSString *url = [NSString stringWithFormat:@"/repos/%@/contents/%@", self.fullName, path];
    
    if (!needRefresh) {
        NSArray *cacheArray = [[KVStoreManager sharedStore] getObjectById:url fromTable:kReposContentsTableName];

        if (cacheArray) {
            for (NSDictionary *dic in cacheArray) {
                GITRepositoryContent *content = [GITRepositoryContent objectWithKeyValues:dic];
                content.repoFullName = self.fullName;
                [array addObject:content];
            }
            NSLog(@"hit cache");
            success([array copy]);
            return nil;
        }
    }
    
    NSLog(@"not hit cache or need refresh");
    
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        
        [self storeContentsArray:obj forKey:url];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dic in obj) {
            GITRepositoryContent *content = [GITRepositoryContent objectWithKeyValues:dic];
            content.repoFullName = self.fullName;
            [array addObject:content];
        }
        success([array copy]);
    } failure:failure];
}

//TODO: wifi 环境下用 tree，否则逐步用 contentOfPath 方法
//- (AFHTTPRequestOperation *)treeOfSha:(NSString *)sha
//                              success:(void (^)(NSArray *))success
//                              failure:(GitHubClientFailureBlock)failure
//{
//    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
//    [client setValue:@"application/vnd.github.VERSION.html" forHeader:@"Accept"];
//    
//    sha = sha ?:@"";
//    NSString *url = [NSString stringWithFormat:@"/repos/%@/git/trees/%@?", self.fullName, sha];
//    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
//        NSMutableArray *array = [NSMutableArray array];
//        for (NSDictionary *dic in obj) {
//            GITRepositoryContent *content = [GITRepositoryContent objectWithKeyValues:dic];
//            content.repoFullName = self.fullName;
//            [array addObject:content];
//        }
//        success([array copy]);
//    } failure:failure];
//}

#pragma mark - Private

- (NSString *)repositoryTypeToString:(JGHRepositoryType)type
{
    NSArray *repositoryType = @[@"all", @"owner", @"public", @"private", @"member", @"forks", @"sources"];
    return repositoryType[type];
}

+ (NSArray *)jsonArrayToModelArray:(NSArray *)array
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        GITRepository *item = [GITRepository objectWithKeyValues:dict];
        [mutableArray addObject:item];
    }
    return [mutableArray copy];
}

+ (AFHTTPRequestOperation *)repositoriesOfUrl:(NSString *)url
                                   parameters:(NSDictionary *)parameters
                                      success:(void (^)(NSArray *))success
                                      failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client getWithURL:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id obj) {
        success(obj);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)myStarredRepositoriesNeedRefresh:(BOOL)needRefresh
                                                  parameters:(NSDictionary *)parameters
                                                     success:(void (^)(NSArray *))success
                                                     failure:(GitHubClientFailureBlock)failure
{
    // 不需要刷新，且没有带分页参数，直接读取本地缓存
    if (!needRefresh && !parameters) {
        NSArray *cachedRepos = [GITRepository getCachedObjectByKey:MyStarredRepositories];
        if (cachedRepos) {
            success([GITRepository jsonArrayToModelArray:cachedRepos]);
            return nil;
        }
    }
    NSString *url = [NSString stringWithFormat:@"/users/%@/starred?sort=created", [GITUser username]];
    return [GITRepository repositoriesOfUrl:url parameters:parameters success:^(NSArray *repos) {
        // 每次调用 API 成功获取之后都保存到本地
        BOOL pagination = parameters ? YES : NO;
        [GITRepository storeObject:repos byKey:MyStarredRepositories pagination:pagination];

        success([GITRepository jsonArrayToModelArray:repos]);
    } failure:failure];
}

+ (AFHTTPRequestOperation *)myRepositoriesNeedRefresh:(BOOL)needRefresh
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(NSArray *))success
                                              failure:(GitHubClientFailureBlock)failure
{
    if (!needRefresh && !parameters) {
        NSArray *cachedRepos = [GITRepository getCachedObjectByKey:MyOwnedRepositories];
        if (cachedRepos) {
            success([GITRepository jsonArrayToModelArray:cachedRepos]);
            return nil;
        }
    }
    
    return [GITRepository repositoriesOfUrl:@"/user/repos?sort=created" parameters:parameters success:^(NSArray *repos) {
        // 每次调用 API 成功获取之后都保存到本地
        BOOL pagination = parameters ? YES : NO;
        [GITRepository storeObject:repos byKey:MyOwnedRepositories pagination:pagination];
        success([GITRepository jsonArrayToModelArray:repos]);
    } failure:failure];
}

+ (void)storeObject:(id)obj byKey:(NSString *)key pagination:(BOOL)pagination
{
    [[KVStoreManager sharedStore] createTableWithName:RepositoriesTableName];
    if (pagination) {
        // 先取出旧的已缓存的，再加上分页的
        NSMutableArray *cached = [NSMutableArray arrayWithArray:[GITRepository getCachedObjectByKey:key]];
        [cached addObjectsFromArray:obj];
        [[KVStoreManager sharedStore] putObject:cached withId:key intoTable:RepositoriesTableName];
    }
    else {
        [[KVStoreManager sharedStore] putObject:obj withId:key intoTable:RepositoriesTableName];
    }
    
}

+ (id)getCachedObjectByKey:(NSString *)key
{
    NSLog(@"");
    return [[KVStoreManager sharedStore] getObjectById:key fromTable:RepositoriesTableName];
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
    
    NSString *url = [NSString stringWithFormat:@"/repos/%@/readme", self.fullName];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *dict) {
        
        NSString *base64String = dict[@"content"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *content = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSString *html = [NSString stringWithFormat:MCGitHubHTMLTemplateString, self.fullName, content];
        NSString *formatedHTML = [html stringByReplacingOccurrencesOfString:@"<img src=" withString:@"<img image_src="];
        
        [self storeReadmeHTML:formatedHTML];
        NSLog(@"refresh README ok");
        success(formatedHTML);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 200) {
            NSData *encodedData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            NSString *content = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
            NSString *html = [NSString stringWithFormat:MCGitHubHTMLTemplateString, self.fullName, content];
            NSString *formatedHTML = [html stringByReplacingOccurrencesOfString:@"<img src=" withString:@"<img image_src="];
            
            [self storeReadmeHTML:formatedHTML];
            NSLog(@"refresh README error but ok");
            success(formatedHTML);
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

- (void)storeContentsArray:(NSArray *)array forKey:(NSString *)key
{
    [[KVStoreManager sharedStore] createTableWithName:kReposContentsTableName];
    [[KVStoreManager sharedStore] putObject:array withId:key intoTable:kReposContentsTableName];
}

@end
