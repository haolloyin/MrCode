//
//  UserProfileHeaderView.h
//  MrCode
//
//  Created by hao on 7/19/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GITUser;

@protocol UserProfileHeaderViewDelegate <NSObject>

- (void)tapUserProfileHeaderViewButton:(UIButton *)button;

@end

@interface UserProfileHeaderView : UIView

@property (nonatomic, strong) GITUser *user;
@property (nonatomic, weak) id<UserProfileHeaderViewDelegate> delegate;

@end
