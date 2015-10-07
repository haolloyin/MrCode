//
//  WebViewController.m
//  MrCode
//
//  Created by hao on 8/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "WebViewController.h"

#import "Masonry.h"
#import "WebViewJavascriptBridge.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD.h"


@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *jsBridge;
@property (nonatomic, strong) NSMutableArray* allImages;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
    [self setupJSBridge];
    
    self.navigationItem.title = self.title;
    // FIXME 不知道这里为啥一定要先调用一次，否则之后所有 loadHTMLString 都不会触发 shouldStartLoadWithRequest
    // 文档只是这样说 shouldStartLoadWithRequest 方法 “Sent before a web view begins loading a frame.”
//    [self reloadWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"webView=%@", _webView);
    [self reloadWebView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"");
    [self.webView stopLoading];
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
    if (self.delegate || self.htmlString || self.url) {
        NSLog(@"shouldStartLoadWithRequest");
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
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}

#pragma mark - Public

- (void)reloadWebView
{
    NSLog(@"");
    
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    
    // 优先执行 delegate 中的代码
    if (self.delegate) {
        [self.delegate webViewShouldLoadRequest:self.webView];
    }
    else if (self.htmlString) {
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        [self.webView loadHTMLString:self.htmlString baseURL:baseURL];
    }
    else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

#pragma mark - 下载全部图片

-(void)downloadAllImagesInNative:(NSArray *)imageUrls
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    //初始化一个置空元素数组
    _allImages = [NSMutableArray arrayWithCapacity:imageUrls.count];//本地的一个用于保存所有图片的数组
    for (NSUInteger i = 0; i < imageUrls.count-1; i++) {
        [_allImages addObject:[NSNull null]];
    }
    
    for (NSUInteger i = 0; i < imageUrls.count; i++) {
        NSString *originString = imageUrls[i];
        NSString *imgString = [NSString stringWithString:originString];
        
        // 如果是 NSNull 对象则扔掉
        if ([originString isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        // FIXME: 没有以 http 开头，说明是当前资源库下的相对路径，这个 self.repoFullName 没解耦很丑
        if (![originString hasPrefix:@"http"]) {
            imgString = [NSString stringWithFormat:@"https://github.com/%@/raw/master/%@", self.repoFullName, originString];
        }
        
        NSURL *url = [NSURL URLWithString:imgString];
//        NSLog(@"\noriginString=%@\nimgString=%@", originString, imgString);
        
        [manager downloadImageWithURL:url options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                
            if (image) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //把图片在磁盘中的地址传回给JS
                    NSString *key = [manager cacheKeyForURL:imageURL];
                    NSString *cachedPath = [manager.imageCache defaultCachePathForKey:key];
                    
                    [_jsBridge callHandler:@"imagesDownloadComplete" data:@[originString, cachedPath]];
                });
            }
        }];
    }
}

#pragma mark - Property

- (void)setupJSBridge
{
    // 这里不能用惰性初始化，否则根本没给 webView 的 HTML 注入 WebViewJavascriptBridge 对象
    if (!_jsBridge) {
        _jsBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            
//            NSLog(@"ObjC received message from JS: %@\n%@", [data class], data);
            
            if (data) {
                [self downloadAllImagesInNative:data];
            }
            
            if (responseCallback) {
                responseCallback(@"Response for message from ObjC");
            }
        }];
    }
}

@end
