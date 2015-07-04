//
//  GITUser.h
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubOAuthClient.h"

static NSString *kAUTHENTICATED_USER_IDENTIFIER = @"GitHubOAuthClient_AUTHENTICATED_USER_IDENTIFIER";

@interface GITUser : NSObject

@property (nonatomic, assign          ) NSUInteger publicRepos;
@property (nonatomic, readonly, copy  ) NSString   *siteAdmin;
@property (nonatomic, readonly, strong) NSURL      *subscriptionsURL;
@property (nonatomic, readonly, copy  ) NSString   *gravatarId;
@property (nonatomic, readonly, copy  ) NSString   *hireable;
@property (nonatomic, assign          ) NSUInteger ID;
@property (nonatomic, readonly, strong) NSURL      *followersURL;
@property (nonatomic, readonly, strong) NSURL      *followingURL;
@property (nonatomic, readonly, strong) NSURL      *blog;
@property (nonatomic, assign          ) NSUInteger followers;
@property (nonatomic, readonly, copy  ) NSString   *location;
@property (nonatomic, readonly, copy  ) NSString   *type;
@property (nonatomic, readonly, copy  ) NSString   *email;
@property (nonatomic, readonly, copy  ) NSString   *bio;
@property (nonatomic, readonly, strong) NSURL      *gistsURL;
@property (nonatomic, readonly, copy  ) NSString   *company;
@property (nonatomic, readonly, strong) NSURL      *eventsURL;
@property (nonatomic, readonly, strong) NSURL      *htmlURL;
@property (nonatomic, readonly, copy  ) NSString   *updatedAt;
@property (nonatomic, readonly, strong) NSURL      *receivedEventsURL;
@property (nonatomic, readonly, strong) NSURL      *starredURL;
@property (nonatomic, assign          ) NSUInteger publicGists;
@property (nonatomic, readonly, copy  ) NSString   *name;
@property (nonatomic, readonly, strong) NSURL      *organizationsURL;
@property (nonatomic, readonly, strong) NSURL      *url;
@property (nonatomic, readonly, copy  ) NSString   *createdAt;
@property (nonatomic, readonly, strong) NSURL      *avatarURL;
@property (nonatomic, readonly, strong) NSURL      *reposURL;
@property (nonatomic, readonly, copy  ) NSString   *following;
@property (nonatomic, readonly, copy  ) NSString   *login;

+ (instancetype)currentAuthenticatedUser;

+ (AFHTTPRequestOperation *)authenticatedUserWithSuccess:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)userWithUserName:(NSString *)username success:(void (^)(GITUser *))success failure:(GitHubClientFailureBlock)failure;

@end
