//
//  WebViewController.m
//  MrCode
//
//  Created by hao on 8/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "WebViewController.h"

#import "Masonry.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
    self.navigationItem.title = self.title;
    // FIXME 不知道这里为啥一定要先调用一次，否则之后所有 loadHTMLString 都不会触发 shouldStartLoadWithRequest
    // 文档只是这样说 shouldStartLoadWithRequest 方法 “Sent before a web view begins loading a frame.”
    [self reloadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.htmlString) {
        return YES;
    }
    else if (self.url) {
        return YES;
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"URL=%@", self.url.absoluteString);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark - Public

- (void)reloadWebView
{
    if (self.htmlString) {
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        [self.webView loadHTMLString:self.htmlString baseURL:baseURL];
    }
    else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

@end
