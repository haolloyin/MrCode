//
//  GITOrganization.h
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubOAuthClient.h"
#import "GITBaseModel.h"

@interface GITOrganization : GITBaseModel

@property (nonatomic, assign          ) NSUInteger publicRepos;
@property (nonatomic, assign          ) NSUInteger publicGists;
@property (nonatomic, readonly, copy  ) NSString   *name;
@property (nonatomic, readonly, copy  ) NSDate     *createdAt;
@property (nonatomic, readonly, strong) NSURL      *url;
@property (nonatomic, readonly, copy  ) NSString   *company;
@property (nonatomic, readonly, strong) NSURL      *htmlURL;
@property (nonatomic, readonly, copy  ) NSString   *email;
@property (nonatomic, readonly, strong) NSURL      *blog;
@property (nonatomic, readonly, strong) NSURL      *avatarURL;
@property (nonatomic, assign          ) NSUInteger followers;
@property (nonatomic, readonly, copy  ) NSString   *location;
@property (nonatomic, readonly, copy  ) NSString   *following;
@property (nonatomic, readonly, copy  ) NSString   *login;
@property (nonatomic, readonly, copy  ) NSString   *type;
@property (nonatomic, assign          ) NSUInteger ID;
@property (nonatomic, readonly, copy  ) NSString   *desc;

+ (AFHTTPRequestOperation *)myOrganizationsWithSuccess:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)organizationsOfUser:(NSString *)user
                                        success:(void (^)(NSArray *))success
                                        failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)infoOfOrganization:(NSString *)orgName
                                       success:(void (^)(GITOrganization *))success
                                       failure:(GitHubClientFailureBlock)failure;

@end
