//
//  GitHubOAuthClient.h
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"

/**
 *  GitHubOAuthClient
 */

typedef void(^GitHubClientSuccessBlock)(AFHTTPRequestOperation *operation, id responseObjct);
typedef void(^GitHubClientFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

typedef NS_ENUM(NSUInteger, GitHubOAuthClienAPIStatus) {
    GitHubOAuthClienAPIStatus200_OK           = 200,
    GitHubOAuthClienAPIStatus400_BadRequest   = 400,
    GitHubOAuthClienAPIStatus401_Unauthorized = 401,
    GitHubOAuthClienAPIStatus403_Forbidden    = 403,
    GitHubOAuthClienAPIStatus404_NotFound     = 404
};

@interface GitHubOAuthClient : NSObject <NSCoding>

@property (nonatomic, assign, readonly) BOOL alreadyOAuth;

#pragma mark - Initial

+ (instancetype)sharedInstance;

- (void)setupWithClientID:(NSString *)clientID
                   secret:(NSString *)secret
                  baseURL:(NSString *)baseURL
             authorizeURL:(NSString *)authorizeURL
              redirectURL:(NSString *)redirectURL
           accessTokenURL:(NSString *)accessTokenURL;

#pragma mark - Property

- (NSString *)redirectURLString;

#pragma mark - OAuth

- (void)authorizeWithScope:(NSString *)scope;

- (void)handleRedirectURL:(NSURL *)url;

#pragma mark - HTTP

+ (AFHTTPRequestOperationManager *)httpManager;

- (void)setValue:(NSString *)value forHeader:(NSString *)header;

- (void)setAcceptableContentTypes:(NSString *)contentTypes;

- (AFHTTPRequestOperation *)getWithURL:(NSString *)url
                            parameters:(NSDictionary *)parameters
                               success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                               failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)postWithURL:(NSString *)url
                             parameters:(NSDictionary *)parameters
                                success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)putWithURL:(NSString *)url
                            parameters:(NSDictionary *)parameters
                               success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                               failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)patchWithURL:(NSString *)url
                              parameters:(NSDictionary *)parameters
                                 success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)deleteWithURL:(NSString *)url
                               parameters:(NSDictionary *)parameters
                                  success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                  failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
