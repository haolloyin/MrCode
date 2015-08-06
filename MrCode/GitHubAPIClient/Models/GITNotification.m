//
//  GITNotification.m
//  GitHubAPIClient
//
//  Created by hao on 6/30/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITNotification.h"

@implementation GITNotification

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"repository": @"repository",
             @"url": @"url",
             @"updatedAt": @"updated_at",
             @"lastReadAt": @"last_read_at",
             @"reason": @"reason",
             @"isUnread": @"unread",
             @"ID": @"id",
             @"subjectURL": @"subject.url",
             @"latestCommentURL": @"subject.latest_comment_url",
             @"subjectType": @"subject.type",
             @"subjectTitle": @"subject.title"
             };
}

#pragma mark - Private

+ (AFHTTPRequestOperation *)notificationsWithUrl:(NSString *)url
                                         success:(void (^)(NSArray *))success
                                         failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITNotification *notification = [GITNotification objectWithKeyValues:dict];
            [mutableArray addObject:notification];
        }
        success([mutableArray copy]);
    } failure:failure];
}

#pragma mark - API

+ (AFHTTPRequestOperation *)myNotificationsWithSuccess:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure
{
    return [GITNotification notificationsWithUrl:@"/notifications" success:success failure:failure];
}

+ (AFHTTPRequestOperation *)notificationsOfUser:(NSString *)user
                                     repository:(NSString *)repo
                                        success:(void (^)(NSArray *))success
                                        failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/repos/%@/%@/notifications", user, repo];
    return [GITNotification notificationsWithUrl:url success:success failure:failure];
}

+ (AFHTTPRequestOperation *)markAsReadOfUser:(NSString *)user
                                  repository:(NSString *)repo
                                     success:(void (^)(BOOL))success
                                     failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/repos/%@/%@/notifications", user, repo];
    
    return [client putWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        if (operation.response.statusCode == 205) {
            success(YES);
        }
    } failure:failure];
    
}

+ (AFHTTPRequestOperation *)notificationOfThreadId:(NSString *)threadId
                                           success:(void (^)(NSArray *))success
                                           failure:(GitHubClientFailureBlock)failure
{
    NSString *url = [NSString stringWithFormat:@"/notifications/threads/%@", threadId];
    return [GITNotification notificationsWithUrl:url success:success failure:failure];
}

+ (AFHTTPRequestOperation *)markAsReadOfThreadId:(NSString *)threadId
                                         success:(void (^)(BOOL))success
                                         failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    NSString *url = [NSString stringWithFormat:@"/notifications/threads/%@", threadId];
    
    return [client patchWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        if (operation.response.statusCode == 205) {
            success(YES);
        }
    } failure:failure];
}

- (NSURL *)htmlURL
{
    NSString *tmpSring = [self.subjectURL.absoluteString stringByReplacingOccurrencesOfString:@"https://api.github.com/repos"
                                                                                   withString:@"https://github.com"];
    return [NSURL URLWithString:tmpSring];
}

@end
