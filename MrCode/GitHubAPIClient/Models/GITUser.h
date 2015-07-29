//
//  GITUser.h
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubOAuthClient.h"
#import "GITBaseModel.h"

static NSString *kAUTHENTICATED_USER_IDENTIFIER = @"GitHubOAuthClient_AUTHENTICATED_USER_IDENTIFIER";

@interface GITUser : GITBaseModel

@property (nonatomic, readonly, copy  ) NSString   *login;
@property (nonatomic, assign          ) NSUInteger ID;
@property (nonatomic, readonly, strong) NSURL      *avatarURL;
@property (nonatomic, readonly, copy  ) NSString   *gravatarId;
@property (nonatomic, readonly, strong) NSURL      *url;
@property (nonatomic, readonly, strong) NSURL      *htmlURL;
@property (nonatomic, readonly, strong) NSURL      *followersURL;
@property (nonatomic, readonly, strong) NSURL      *followingURL;
@property (nonatomic, readonly, strong) NSURL      *gistsURL;
@property (nonatomic, readonly, strong) NSURL      *starredURL;
@property (nonatomic, readonly, strong) NSURL      *subscriptionsURL;
@property (nonatomic, readonly, strong) NSURL      *organizationsURL;
@property (nonatomic, readonly, strong) NSURL      *reposURL;
@property (nonatomic, readonly, strong) NSURL      *eventsURL;
@property (nonatomic, readonly, strong) NSURL      *receivedEventsURL;

@property (nonatomic, readonly, copy  ) NSString   *type;
@property (nonatomic, readonly, copy  ) NSString   *name;
@property (nonatomic, readonly, copy  ) NSString   *company;
@property (nonatomic, readonly, strong) NSURL      *blog;
@property (nonatomic, readonly, copy  ) NSString   *location;
@property (nonatomic, readonly, copy  ) NSString   *email;
@property (nonatomic, readonly, copy  ) NSString   *bio;
@property (nonatomic, assign          ) BOOL       isSiteAdmin;
@property (nonatomic, assign          ) BOOL       isHireable;

@property (nonatomic, assign          ) NSUInteger publicRepos;
@property (nonatomic, assign          ) NSUInteger publicGists;
@property (nonatomic, assign          ) NSUInteger followers;
@property (nonatomic, assign          ) NSUInteger following;

@property (nonatomic, readonly, strong) NSDate     *updatedAt;
@property (nonatomic, readonly, strong) NSDate     *createdAt;

+ (NSString *)username;

+ (AFHTTPRequestOperation *)authenticatedUserWithSuccess:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)userWithUserName:(NSString *)username
                                     success:(void (^)(GITUser *))success
                                     failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)followersOfUser:(NSString *)user
                                    success:(void (^)(NSArray *))success
                                    failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)followingOfUser:(NSString *)user
                                    success:(void (^)(NSArray *))success
                                    failure:(GitHubClientFailureBlock)failure;

@end
