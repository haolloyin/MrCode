//
//  GITEvent.h
//  MrCode
//
//  Created by hao on 7/11/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITBaseModel.h"
#import "GitHubOAuthClient.h"

@class GITRepository;
@class GITUser;
@class GITOrganization;

@interface GITEvent : GITBaseModel

@property (nonatomic, copy, readonly  ) NSString        *ID;
@property (nonatomic, copy, readonly  ) NSString        *type;
@property (nonatomic, assign, readonly) BOOL            isPublic;
@property (nonatomic, strong, readonly) NSDate          *createdAt;
@property (nonatomic, strong, readonly) GITUser         *actor;
@property (nonatomic, strong, readonly) GITOrganization *org;

+ (AFHTTPRequestOperation *)eventsOfUser:(NSString *)user success:(void (^)(NSArray *))success failure:(GitHubClientFailureBlock)failure;

@end
