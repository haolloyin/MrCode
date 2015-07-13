//
//  GITSearch.m
//  MrCode
//
//  Created by hao on 7/12/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITSearch.h"
#import "GITRepository.h"
#import "GITUser.h"

@implementation GITSearch

+ (AFHTTPRequestOperation *)searchRepositoriesWith:(NSString *)keyword
                                          language:(NSString *)language
                                            sortBy:(NSString *)sortBy
                                           success:(void (^)(NSArray *))success
                                           failure:(GitHubClientFailureBlock)failure
{
    NSMutableString *url = [NSMutableString stringWithFormat:@"/search/repositories?q=%@", keyword];
    if (language) {
        [url appendFormat:@"+language:%@", language];
    }
    if (sortBy) {
        [url appendFormat:@"&sort=%@", sortBy];
    }
    
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj[@"items"]) {
            GITRepository *repo = [GITRepository objectWithKeyValues:dict];
            [mutableArray addObject:repo];
        }
        success([mutableArray copy]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+ (AFHTTPRequestOperation *)searchDevelopersWith:(NSString *)keyword
                                          sortBy:(NSString *)sortBy
                                         success:(void (^)(NSArray *))success
                                         failure:(GitHubClientFailureBlock)failure
{
    NSMutableString *url = [NSMutableString stringWithFormat:@"/search/users?q=%@", keyword];
    if (sortBy) {
        [url appendFormat:@"&sort=%@", sortBy];
    }
    
    GitHubOAuthClient *client = [GitHubOAuthClient sharedInstance];
    return [client getWithURL:url parameters:nil success:^(AFHTTPRequestOperation *operation, id obj) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in obj[@"items"]) {
            GITUser *user = [GITUser objectWithKeyValues:dict];
            [mutableArray addObject:user];
        }
        success([mutableArray copy]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

@end
