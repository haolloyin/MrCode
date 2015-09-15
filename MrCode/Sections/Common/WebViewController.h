//
//  WebViewController.h
//  MrCode
//
//  Created by hao on 8/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewControllerDelegate <NSObject>

@optional
- (void)webViewShouldLoadRequest:(UIWebView *)webView;

@end

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, weak) id<WebViewControllerDelegate> delegate;

- (void)reloadWebView;

@end
