//
//  UsersTableVC.h
//  MrCode
//
//  Created by hao on 7/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UsersTableVCUserType) {
    UsersTableVCUserTypeFollowing = 0,
    UsersTableVCUserTypeFollower,
    UsersTableVCUserTypeContributor
};

@class GITRepository;

@interface UsersTableVC : UITableViewController

@property (nonatomic, copy) NSString *user;
@property (nonatomic, strong) GITRepository *repo;
@property (nonatomic, assign) UsersTableVCUserType userType;

@end
