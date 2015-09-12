//
//  GITNotification.m
//  GitHubAPIClient
//
//  Created by hao on 6/30/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITNotification.h"
#import "KVStoreManager.h"

static NSString *kNotificationsTableName = @"MrCode_NotificationsTableName";
static NSString *kNotificationsCachedKey = @"MrCode_NotificationsCachedKey";

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
        NSArray *models = [GITNotification jsonArrayToModelArray:obj];
        success(models);
    } failure:failure];
}

+ (NSArray *)jsonArrayToModelArray:(NSArray *)array
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        GITNotification *notification = [GITNotification objectWithKeyValues:dict];
        [mutableArray addObject:notification];
    }
    return [mutableArray copy];
}

+ (void)storeObject:(id)obj byKey:(NSString *)key
{
    NSLog(@"");
    [[KVStoreManager sharedStore] createTableWithName:kNotificationsTableName];
    [[KVStoreManager sharedStore] putObject:obj withId:key intoTable:kNotificationsTableName];
}

+ (id)getCachedObjectByKey:(NSString *)key
{
    NSLog(@"");
    return [[KVStoreManager sharedStore] getObjectById:key fromTable:kNotificationsTableName];
}

#pragma mark - API

+ (AFHTTPRequestOperation *)myNotificationsNeedRefresh:(BOOL)needRefresh
                                               success:(void (^)(NSArray *))success
                                               failure:(GitHubClientFailureBlock)failure
{
    if (!needRefresh) {
        NSArray *array = [GITNotification getCachedObjectByKey:kNotificationsCachedKey];

        if (array) {
            NSLog(@"not need refresh");
            success([GITNotification jsonArrayToModelArray:array]);
            return nil;
        }
    }
    
    NSLog(@"need refresh");
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    return [client getWithURL:@"/notifications" parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        
        [GITNotification storeObject:obj byKey:kNotificationsCachedKey];
        NSArray *models = [GITNotification jsonArrayToModelArray:obj];
        success(models);
    } failure:failure];
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
