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
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"");
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark - Public

- (void)reloadWebView
{
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    // 优先执行 block 中的代码
    if (self.loadRequestBlock) {
        NSLog(@"loadRequestBlock");
        self.htmlString = self.loadRequestBlock();
        
        if (self.htmlString) {
            [self.webView loadHTMLString:self.htmlString baseURL:baseURL];
        }
    }
    else if (self.htmlString) {
        [self.webView loadHTMLString:self.htmlString baseURL:baseURL];
    }
    else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

#pragma mark -- 下载全部图片

-(void)downloadAllImagesInNative:(NSArray *)imageUrls
{
    NSLog(@"downloadAllImagesInNative");
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    //初始化一个置空元素数组
    _allImages = [NSMutableArray arrayWithCapacity:imageUrls.count];//本地的一个用于保存所有图片的数组
    for (NSUInteger i = 0; i < imageUrls.count-1; i++) {
        [_allImages addObject:[NSNull null]];
    }
    
    for (NSUInteger i = 0; i < imageUrls.count-1; i++) {
        NSString *url = imageUrls[i];
        
        [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (image) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSString *imgB64 = [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    
                    //把图片在磁盘中的地址传回给JS
                    NSString *key = [manager cacheKeyForURL:imageURL];
                    NSLog(@"imageURL=%@\ncacheURL=%@", imageURL, key);
                    
                    NSString *source = [NSString stringWithFormat:@"data:image/png;base64,%@", imgB64];
                    [self.jsBridge callHandler:@"imagesDownloadComplete" data:@[key,source]];
                });
            }
        }];
    }
}

#pragma mark - Property

- (WebViewJavascriptBridge *)jsBridge
{
    if (!_jsBridge) {
        _jsBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"ObjC received message from JS: %@", data);
            responseCallback(@"Response for message from ObjC");
        }];
    }
    return _jsBridge;
}

@end
