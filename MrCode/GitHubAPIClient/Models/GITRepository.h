//
//  GITRepository.h
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubOAuthClient.h"
#import "GITBaseModel.h"
#import "GITUser.h"

@interface GITRepositoryContent : GITBaseModel

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *path;
@property (nonatomic, readonly, copy) NSString *sha;
@property (nonatomic, readonly, copy) NSString *type;
@property (nonatomic, readonly, copy) NSString *content; // 当 type 是 file 这里是 base64 编码后的内容
@property (nonatomic, assign        ) NSUInteger size;
@property (nonatomic, readwrite, copy) NSString *repoFullName;

@property (nonatomic, readonly, strong) NSURL  *url;
@property (nonatomic, readonly, strong) NSURL  *htmlURL;
@property (nonatomic, readonly, strong) NSURL  *gitURL;
@property (nonatomic, readonly, strong) NSURL  *downloadURL;
@property (nonatomic, readonly, strong) NSURL  *linksSelfURL;
@property (nonatomic, readonly, strong) NSURL  *linksGitURL;
@property (nonatomic, readonly, strong) NSURL  *linksHtmlURL;

- (NSString *)apiPath;

- (AFHTTPRequestOperation *)fileOfPath:(NSString *)path
                           needRefresh:(BOOL)needRefresh
                               success:(void (^)(NSString *))success
                               failure:(GitHubClientFailureBlock)failure;

@end



typedef NS_ENUM(NSUInteger, JGHRepositoryType) {
    JGHRepositoryTypeAll,
    JGHRepositoryTypeOwner,
    JGHRepositoryTypePublic,
    JGHRepositoryTypePrivate,
    JGHRepositoryTypeMember,
    JGHRepositoryTypeForks,
    JGHRepositoryTypeSources
};

typedef NS_ENUM(NSUInteger, JGHRepositorySortBy) {
    JGHRepositorySortByCreated,
    JGHRepositorySortByUpdated,
    JGHRepositorySortByPushed,
    JGHRepositorySortByFullname
};

typedef NS_ENUM(NSUInteger, JGHRepositoryOrderBy) {
    JGHRepositoryOrderByAsc,
    JGHRepositoryOrderByDesc,
};

@interface GITRepository : GITBaseModel

@property (nonatomic, assign          ) NSUInteger forksCount;
@property (nonatomic, assign          ) NSUInteger watchersCount;
@property (nonatomic, assign          ) NSUInteger stargazersCount;
@property (nonatomic, assign          ) NSUInteger openIssuesCount;
@property (nonatomic, assign          ) NSUInteger ID;
@property (nonatomic, assign          ) NSUInteger size;
@property (nonatomic, strong          ) GITUser    *owner;
@property (nonatomic, readonly, strong) NSURL      *url;
@property (nonatomic, readonly, strong) NSURL      *cloneURL;
@property (nonatomic, readonly, strong) NSURL      *homepage;
@property (nonatomic, readonly, strong) NSURL      *htmlURL;
@property (nonatomic, readonly, strong) NSURL      *gitURL;
@property (nonatomic, assign          ) BOOL       isForked;
@property (nonatomic, assign          ) BOOL       hasWiki;
@property (nonatomic, assign          ) BOOL       hasPages;
@property (nonatomic, assign          ) BOOL       hasIssues;
@property (nonatomic, assign          ) BOOL       isPrivate;
@property (nonatomic, readonly, copy  ) NSString   *desc;
@property (nonatomic, readonly, copy  ) NSString   *defaultBranch;
@property (nonatomic, readonly, copy  ) NSString   *name;
@property (nonatomic, readonly, copy  ) NSString   *fullName;
@property (nonatomic, readonly, copy  ) NSString   *language;
@property (nonatomic, readonly, strong) NSDate     *updatedAt;
@property (nonatomic, readonly, strong) NSDate     *createdAt;
@property (nonatomic, readonly, strong) NSDate     *pushedAt;

+ (BOOL)isStarredRepo:(GITRepository *)repo;

+ (AFHTTPRequestOperation *)repositoriesOfUser:(NSString *)user
                                   needRefresh:(BOOL)needRefresh
                                    parameters:(NSDictionary *)parameters
                                       success:(void (^)(NSArray *))success
                                       failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)starredRepositoriesByUser:(NSString *)user
                                          needRefresh:(BOOL)needRefresh
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(NSArray *))success
                                              failure:(GitHubClientFailureBlock)failure;

// https://developer.github.com/v3/repos/forks/#list-forks
//+ (AFHTTPRequestOperation *)forksOfRepository:(GITRepository *)repo
//                                      success:(void (^)(NSArray *))success
//                                      failure:(GitHubClientFailureBlock)failure;

// https://developer.github.com/v3/repos/forks/#list-forks
+ (AFHTTPRequestOperation *)forksOfRepository:(NSString *)repoName
                                   parameters:(NSDictionary *)parameters
                                      success:(void (^)(NSArray *))success
                                      failure:(GitHubClientFailureBlock)failure;

- (AFHTTPRequestOperation *)contributorsWithSuccess:(void (^)(NSArray *))success
                                            failure:(GitHubClientFailureBlock)failure;


+ (AFHTTPRequestOperation *)starRepository:(GITRepository *)repo
                                   success:(void (^)(BOOL))success
                                   failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)unstarRepository:(GITRepository *)repo
                                     success:(void (^)(BOOL))success
                                     failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)watchRepository:(GITRepository *)repo
                                    success:(void (^)(BOOL))success
                                    failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)unwatchRepository:(GITRepository *)repo
                                    success:(void (^)(BOOL))success
                                    failure:(GitHubClientFailureBlock)failure;

- (AFHTTPRequestOperation *)isWatching:(void (^)(BOOL))isWatching
                               failure:(GitHubClientFailureBlock)failure;

- (AFHTTPRequestOperation *)forksWithSuccess:(void (^)(BOOL))success
                                   failure:(GitHubClientFailureBlock)failure;

- (AFHTTPRequestOperation *)readmeWithsuccess:(void (^)(NSString *))success
                                      failure:(GitHubClientFailureBlock)failure
                                  needRefresh:(BOOL)refresh;

- (AFHTTPRequestOperation *)contentsOfPath:(NSString *)path
                               needRefresh:(BOOL)needRefresh
                                   success:(void (^)(NSArray *))success
                                   failure:(GitHubClientFailureBlock)failure;

@end
