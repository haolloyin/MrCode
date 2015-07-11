//
//  NotificationTableViewCell.h
//  MrCode
//
//  Created by hao on 7/11/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GITNotification;

@protocol NotificationTableViewCellRepoNameTapped <NSObject>

- (void)notificationTabViewCellRepoNameTapped:(GITNotification *)notification;

@end

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) GITNotification *notification;
@property (nonatomic, weak) id<NotificationTableViewCellRepoNameTapped> delegate;

@end
