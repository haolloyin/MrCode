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

+ (AFHTTPRequestOperation *)searchRepositoriesWith:(NSString *)keyword
                                          language:(NSString *)language
                                            sortBy:(NSString *)sortBy
                                           success:(void (^)(NSArray *))success
                                           failure:(GitHubClientFailureBlock)failure;

+ (AFHTTPRequestOperation *)searchDevelopersWith:(NSString *)keyword
                                          sortBy:(NSString *)sortBy
                                         success:(void (^)(NSArray *))success
                                         failure:(GitHubClientFailureBlock)failure;

@end
