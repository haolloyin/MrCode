//
//  GITNotification.h
//  GitHubAPIClient
//
//  Created by hao on 6/30/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GitHubOAuthClient.h"
#import "GITBaseModel.h"
#import "GITRepository.h"

@interface GITNotification : GITBaseModel

@property (nonatomic, readonly, copy  ) NSString      *ID;
@property (nonatomic, strong          ) GITRepository *repository;
@property (nonatomic, readonly, strong) NSURL         *subjectURL;
@property (nonatomic, readonly, strong) NSURL         *subjectLatestCommentURL;
@property (nonatomic, readonly, copy  ) NSString      *subjectType;
@property (nonatomic, readonly, copy  ) NSString      *subjectTitle;
@property (nonatomic, readonly, strong) NSURL         *url;
@property (nonatomic, readonly, copy  ) NSDate        *updatedAt;
@property (nonatomic, readonly, copy  ) NSDate        *lastReadAt;
@property (nonatomic, readonly, copy  ) NSString      *reason;
@property (nonatomic, assign          ) BOOL          isUnread;

+ (AFHTTPRequestOperation *)myNotificationsWithSuccess:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)notificationsOfUser:(NSString *)user
                                     repository:(NSString *)repo
                                        success:(void (^)(NSArray *))success
                                        failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)markAsReadOfUser:(NSString *)user
                                  repository:(NSString *)repo
                                     success:(void (^)(BOOL))success
                                     failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)notificationOfThreadId:(NSString *)threadId
                                           success:(void (^)(NSArray *))success
                                           failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)markAsReadOfThreadId:(NSString *)threadId
                                         success:(void (^)(BOOL))success
                                         failure:(GitHubClientFailureBlock)failure;

- (NSURL *)htmlURL;

@end
