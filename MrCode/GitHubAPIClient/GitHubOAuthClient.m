//
//  GitHubOAuthClient.m
//  GitHubAPIClient
//
//  Created by hao on 6/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GitHubOAuthClient.h"
#import "GITUser.h"

static NSString *kTOKEN_STORE_IDENTIFIER = @"GitHubOAuthClient_TOKEN_STORE_IDENTIFIER";

#pragma mark - GitHubOAuthClient

@interface GitHubOAuthClient ()

@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic, copy) NSString *tokenType;

@property (readwrite, nonatomic, copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;

@property (readwrite, nonatomic, copy) NSString *baseURL;
@property (readwrite, nonatomic, copy) NSString *authorizeURL;
@property (readwrite, nonatomic, copy) NSString *redirectURL;
@property (readwrite, nonatomic, copy) NSString *accessTokenURL;

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end

@implementation GitHubOAuthClient

#pragma mark - Initial

+ (instancetype)sharedInstance
{
    static GitHubOAuthClient *singleInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // init from NSUserDefaults first
        NSData *data   = [[NSUserDefaults standardUserDefaults] objectForKey:kTOKEN_STORE_IDENTIFIER];
        singleInstance = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"singleInstance: %@, nil = %d", singleInstance, singleInstance == nil);
        
        if (!singleInstance) {
            singleInstance = [[GitHubOAuthClient alloc] init];
        }
        
        // AFHTTPRequestOperationManager
        singleInstance.requestManager = [AFHTTPRequestOperationManager manager];
        [singleInstance setRequestManagerAuthosizationHeader];
    });
    
    return singleInstance;
}

- (void)setupWithClientID:(NSString *)clientID
                   secret:(NSString *)secret
                  baseURL:(NSString *)baseURL
             authorizeURL:(NSString *)authorizeURL
              redirectURL:(NSString *)redirectURL
           accessTokenURL:(NSString *)accessTokenURL;
{
    _clientID       = clientID;
    _secret         = secret;
    _baseURL        = baseURL;
    _authorizeURL   = authorizeURL;
    _redirectURL    = redirectURL;
    _accessTokenURL = accessTokenURL;
}

#pragma mark - Property

- (NSString *)redirectURLString
{
    return [self.redirectURL lowercaseString];
}

#pragma mark - OAuth

/**
 *  Step 1. Redirect users to request GitHub access. This method will open Safari for authorize.
 *          see https://developer.github.com/v3/oauth/#redirect-users-to-request-github-access
 *
 *  @param scope <#scope description#>
 */
- (void)authorizeWithScope:(NSString *)scope
{
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&scope=%@&redirect_uri=%@",
                           _authorizeURL, _clientID, scope, _redirectURL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        NSLog(@"can open url: %@", urlString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

/**
 *  Step 2. GitHub redirects back to your `redirect_uri`, we should get the `code` for request the `Access Token`.
 *          see https://developer.github.com/v3/oauth/#github-redirects-back-to-your-site
 *
 *  Note: this method should be called `AppDelegate.m`'s method `-[AppDelegate application: openURL: sourceApplication: annotation:]`.
 *
 *  @param url <#url description#>
 */
- (void)handleRedirectURL:(NSURL *)url
{
    NSString *urlString      = [[url absoluteString] lowercaseString];
    NSString *redirectString = [[NSString stringWithFormat:@"%@?code=", _redirectURL] lowercaseString];
    
    if ([urlString hasPrefix:redirectString]) {
        NSString *code = [urlString stringByReplacingOccurrencesOfString:redirectString withString:@""];
        NSLog(@"code=%@", code);
        [self requestAccessTokenWithCode:code];
    }
}

/**
 *  Step 3. Request for `Access Token` using the `code` from Step 2.
 *
 *  @param code <#code description#>
 */
- (void)requestAccessTokenWithCode:(NSString *)code
{
    [self.requestManager POST:_accessTokenURL
                   parameters:@{@"client_id": _clientID, @"client_secret": _secret, @"code": code}
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                              NSDictionary *dict = responseObject;
                              
                              // store token
                              [self storeWithAccessToken:dict[@"access_token"] tokenType:dict[@"token_type"]];
                              
                              //TODO: 这里用异步可能有问题
                              // current authorized user
                              [GITUser authenticatedUserWithSuccess:^(GITUser *user) {
                                  NSLog(@"%@", user.login);
                              } failure:^(AFHTTPRequestOperation *oper, NSError *error) {
                                  NSLog(@"error: %@", error);
                              }];
                          }
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"error: %@", error);
                      }];
}

- (void)storeWithAccessToken:(NSString *)accessToken tokenType:(NSString *)tokenType
{
    NSLog(@"");
    self.accessToken  = accessToken;
    self.tokenType    = tokenType;
    self.alreadyOAuth = YES;
    NSData *data      = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kTOKEN_STORE_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setRequestManagerAuthosizationHeader];
}

- (void)removeTokenIfUnauthorizedWithOperation:(AFHTTPRequestOperation *)operation
{
    // Maybe user revoke authorized application from https://github.com/settings/applications
    if (operation.response.statusCode == GitHubOAuthClienAPIStatus401_Unauthorized) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTOKEN_STORE_IDENTIFIER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.alreadyOAuth = NO;
    }
}

- (void)setValue:(NSString *)value forHeader:(NSString *)header
{
    [_requestManager.requestSerializer setValue:value forHTTPHeaderField:header];
}

- (void)setAcceptableContentTypes:(NSString *)contentTypes
{
    // 同时需要把默认的 requestSerializer Accept 头部去掉
//    [self setValue:nil forHeader:@"Accept"];
    [_requestManager.responseSerializer.acceptableContentTypes setByAddingObject:contentTypes];
}

#pragma mark - Private

- (void)setRequestManagerAuthosizationHeader
{
    // 默认的 Accept 头部
    [self setValue:@"application/json" forHeader:@"Accept"];
    
    if (self.accessToken) {
        NSString *value = [NSString stringWithFormat:@"Bearer %@", _accessToken];
        [_requestManager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    }
}

- (AFHTTPRequestOperation *)requestUrl:(NSString *)url
                                method:(NSString *)method
                            parameters:(NSDictionary *)parameters
                               success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                               failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseURL, url];
    NSLog(@"Method: %@, URL: %@", method, urlString);
    
    if ([method isEqualToString:@"GET"]) {
        return [self.requestManager GET:urlString
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                    NSLog(@"response: %@, %@,", [responseObject class], responseObject);
                                    success(operation, responseObject);
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [self removeTokenIfUnauthorizedWithOperation:operation];
//                                    NSLog(@"error: %@", error);
                                    failure(operation, error);
                                }];
    } else if ([method isEqualToString:@"POST"]) {
        return [self.requestManager POST:urlString
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                     NSLog(@"response: %@, %@,", [responseObject class], responseObject);
                                     success(operation, responseObject);
                                     
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [self removeTokenIfUnauthorizedWithOperation:operation];
                                     NSLog(@"error: %@", error);
                                     failure(operation, error);
                                 }];
    } else if ([method isEqualToString:@"PUT"]) {
        return [self.requestManager PUT:urlString
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"response: %@, %@,", [responseObject class], responseObject);
                                    success(operation, responseObject);
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [self removeTokenIfUnauthorizedWithOperation:operation];
                                    NSLog(@"error: %@", error);
                                    failure(operation, error);
                                }];
    } else if ([method isEqualToString:@"PATCH"]) {
        return [self.requestManager PATCH:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSLog(@"response: %@, %@,", [responseObject class], responseObject);
                                      success(operation, responseObject);
                                    
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [self removeTokenIfUnauthorizedWithOperation:operation];
                                      NSLog(@"error: %@", error);
                                      failure(operation, error);
                                  }];
    } else if ([method isEqualToString:@"DELETE"]) {
        return [self.requestManager DELETE:urlString
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSLog(@"response: %@, %@,", [responseObject class], responseObject);
                                       success(operation, responseObject);
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [self removeTokenIfUnauthorizedWithOperation:operation];
                                       NSLog(@"error: %@", error);
                                       failure(operation, error);
                                   }];
    }
    return nil;
}

#pragma mark - HTTP

- (AFHTTPRequestOperation *)getWithURL:(NSString *)url
                            parameters:(NSDictionary *)parameters
                               success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                               failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self requestUrl:url method:@"GET" parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)postWithURL:(NSString *)url
                             parameters:(NSDictionary *)parameters
                                success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self requestUrl:url method:@"POST" parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)putWithURL:(NSString *)url
                            parameters:(NSDictionary *)parameters
                               success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                               failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self requestUrl:url method:@"PUT" parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)patchWithURL:(NSString *)url
                              parameters:(NSDictionary *)parameters
                                 success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                 failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self requestUrl:url method:@"PATCH" parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)deleteWithURL:(NSString *)url
                               parameters:(NSDictionary *)parameters
                                  success:(void(^)(AFHTTPRequestOperation *operation, id obj))success
                                  failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self requestUrl:url method:@"DELETE" parameters:parameters success:success failure:failure];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSLog(@"");
    self = [super init];
    self.accessToken    = [decoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))];
    self.tokenType      = [decoder decodeObjectForKey:NSStringFromSelector(@selector(tokenType))];
    self.clientID       = [decoder decodeObjectForKey:NSStringFromSelector(@selector(clientID))];
    self.secret         = [decoder decodeObjectForKey:NSStringFromSelector(@selector(secret))];
    
    self.baseURL        = [decoder decodeObjectForKey:NSStringFromSelector(@selector(baseURL))];
    self.authorizeURL   = [decoder decodeObjectForKey:NSStringFromSelector(@selector(authorizeURL))];
    self.redirectURL    = [decoder decodeObjectForKey:NSStringFromSelector(@selector(redirectURL))];
    self.accessTokenURL = [decoder decodeObjectForKey:NSStringFromSelector(@selector(accessTokenURL))];
    
    self.alreadyOAuth   = [decoder decodeBoolForKey:NSStringFromSelector(@selector(alreadyOAuth))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSLog(@"");
    [encoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    [encoder encodeObject:self.tokenType forKey:NSStringFromSelector(@selector(tokenType))];
    [encoder encodeObject:self.clientID forKey:NSStringFromSelector(@selector(clientID))];
    [encoder encodeObject:self.secret forKey:NSStringFromSelector(@selector(secret))];
    
    [encoder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];
    [encoder encodeObject:self.authorizeURL forKey:NSStringFromSelector(@selector(authorizeURL))];
    [encoder encodeObject:self.redirectURL forKey:NSStringFromSelector(@selector(redirectURL))];
    [encoder encodeObject:self.accessTokenURL forKey:NSStringFromSelector(@selector(accessTokenURL))];
    
    [encoder encodeBool:self.alreadyOAuth forKey:NSStringFromSelector(@selector(alreadyOAuth))];
}

@end
