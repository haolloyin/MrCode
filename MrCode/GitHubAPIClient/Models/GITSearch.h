//
//  GITSearch.h
//  MrCode
//
//  Created by hao on 7/12/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITBaseModel.h"
#import "GitHubOAuthClient.h"

@interface GITSearch : GITBaseModel

+ (AFHTTPRequestOperation *)repositoriesWithKeyword:(NSString *)keyword
                                           language:(NSString *)language
                                             sortBy:(NSString *)sortBy
                                            success:(void (^)(NSArray *))success
                                            failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)developersWithKeyword:(NSString *)keyword
                                           sortBy:(NSString *)sortBy
                                          success:(void (^)(NSArray *))success
                                          failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)trendingReposOfLanguage:(NSString *)language
                                              since:(NSString *)since
                                            success:(void (^)(NSArray *))repos
                                            failure:(GitHubClientFailureBlock)failure;


@end
