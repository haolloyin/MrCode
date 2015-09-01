//
//  WebViewController.h
//  MrCode
//
//  Created by hao on 8/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *htmlString;

- (void)reloadWebView;

@end
