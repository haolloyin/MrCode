//
//  GITEvent.m
//  MrCode
//
//  Created by hao on 7/11/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITEvent.h"
#import "GITUser.h"

@implementation GITEvent

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"ID": @"id",
             @"type": @"type",
             @"isPublic": @"public",
             @"createdAt": @"created_at",
             @"actor": @"actor",
             @"org": @"org"
             };
}

+ (AFHTTPRequestOperation *)eventsOfUser:(NSString *)user success:(void (^)(NSArray *))success failure:(GitHubClientFailureBlock)failure
{
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];

    NSString *url = nil;
    if (user) {
        url = [NSString stringWithFormat:@"/users/%@/received_events/public", user];
    } else {
        url = [NSString stringWithFormat:@"/users/%@/received_events", [GITUser username]];
    }

    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj) {
            GITEvent *event = [GITEvent objectWithKeyValues:dict];
            [mutableArray addObject:event];
        }
        success([mutableArray copy]);
    } failure:failure];
}

@end
