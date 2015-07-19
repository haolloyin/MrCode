//
//  UserProfileTableVC.h
//  MrCode
//
//  Created by hao on 7/19/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GITUser;

@interface UserProfileTableVC : UITableViewController

@property (nonatomic, strong) GITUser *user;

@end
